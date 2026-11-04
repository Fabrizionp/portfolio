"""Synthetic multi-channel e-commerce rows for the reference stack.

Deterministic: the same seed writes the same CSVs, so the committed seeds are reproducible and CI can prove
that nobody edited them by hand (`--check`). Nothing here is a client row: the brand, the products, the
customers and every number are made up for this portfolio.

The data carries the situations the pipeline has to handle:
- orders whose status changed after the first load (the later version must win);
- order lines delivered twice, the second time with the corrected quantity (the correction must win);
- cancelled orders (never a sale);
- inventory snapshots delivered twice (the duplicate must not double the stock);
- stocking channels (AWD, the Shopify 3PL) whose demand is the sales of the channels they supply.
"""
from __future__ import annotations

import argparse
import csv
import io
import math
import random
import sys
from collections import defaultdict
from datetime import date, datetime, timedelta
from pathlib import Path

SEED = 20261031
AS_OF = date(2026, 10, 31)           # the day the Gold tables describe (dbt var `as_of_date`)
ORDER_DAYS = 90                      # orders from AS_OF - 89 to AS_OF
SNAPSHOT_DAYS = 30                   # inventory snapshots from AS_OF - 29 to AS_OF
SEEDS_DIR = Path(__file__).resolve().parents[1] / "dbt" / "seeds"

CHANNEL_FIELDS = ["channel_code", "channel_name", "kind", "supplied_from", "sells",
                  "lead_time_days", "purchase_frequency_days", "safety_days"]
CHANNELS = [
    ("AWD", "Amazon Warehousing and Distribution", "buy", "", False, 21, 14, 10),
    ("SHOPIFY", "Shopify store, own 3PL", "buy", "", True, 14, 7, 7),
    ("TARGET", "Target marketplace", "buy", "", True, 18, 14, 10),
    ("FBA", "Fulfilled by Amazon", "transfer", "AWD", True, 7, 7, 5),
    ("WALMART", "Walmart marketplace", "transfer", "SHOPIFY", True, 5, 7, 5),
]
SALES_MIX = {"FBA": 0.45, "SHOPIFY": 0.25, "TARGET": 0.15, "WALMART": 0.15}

PRODUCT_FIELDS = ["sku", "product_name", "category", "size", "unit_cost", "unit_price", "case_size"]
CATALOG = {
    "Cold therapy": (["Gel Pack", "Knee Wrap", "Shoulder Wrap", "Ankle Wrap", "Back Wrap", "Eye Mask"], ["S", "M", "L"]),
    "Compression": (["Knee Sleeve", "Elbow Sleeve", "Calf Sleeve", "Wrist Brace", "Ankle Sleeve", "Back Brace"], ["S", "M", "L"]),
    "Recovery": (["Massage Ball", "Foam Roller", "Neck Pillow", "Heat Pad", "Posture Band", "Grip Trainer"], ["STD"]),
}
CATEGORY_CODE = {"Cold therapy": "CT", "Compression": "CP", "Recovery": "RC"}
SIZE_COST = {"S": 0.9, "M": 1.0, "L": 1.15, "STD": 1.0}

ORDER_FIELDS = ["order_id", "channel_code", "customer_id", "order_ts", "order_status", "loaded_at"]
LINE_FIELDS = ["order_id", "line_no", "sku", "quantity", "unit_price", "discount", "loaded_at"]
SNAPSHOT_FIELDS = ["snapshot_date", "channel_code", "sku", "on_hand", "on_order", "loaded_at"]


def fmt(ts: datetime) -> str:
    return ts.strftime("%Y-%m-%d %H:%M:%S")


def make_products(rng: random.Random):
    rows, weights = [], []
    for category, (names, sizes) in CATALOG.items():
        for i, name in enumerate(names, 1):
            cost_base = rng.uniform(4.0, 18.0)
            case_size = rng.choice([12, 24, 36])
            popularity = rng.choice([0.4, 0.8, 1.0, 1.0, 1.6, 2.5])
            for size in sizes:
                cost = round(cost_base * SIZE_COST[size], 2)
                price = math.floor(cost * rng.uniform(2.2, 3.2)) + 0.99
                rows.append({
                    "sku": f"NW-{CATEGORY_CODE[category]}-{i:02d}-{size}",
                    "product_name": name if size == "STD" else f"{name} {size}",
                    "category": category,
                    "size": size,
                    "unit_cost": f"{cost:.2f}",
                    "unit_price": f"{price:.2f}",
                    "case_size": case_size,
                })
                weights.append(popularity)
    return rows, weights


def make_orders(rng: random.Random, products, weights):
    orders, lines = [], []
    skus = [p["sku"] for p in products]
    price = {p["sku"]: float(p["unit_price"]) for p in products}
    channels, mix = list(SALES_MIX), list(SALES_MIX.values())
    order_no = 100000
    start = AS_OF - timedelta(days=ORDER_DAYS - 1)
    for d in range(ORDER_DAYS):
        day = start + timedelta(days=d)
        base = 38 + 0.12 * d                       # gentle growth over the quarter
        if day.weekday() >= 5:
            base *= 1.3                            # weekend lift
        n = max(5, int(rng.gauss(base, base * 0.18)))
        for _ in range(n):
            order_no += 1
            order_id = f"O{order_no}"
            channel = rng.choices(channels, mix)[0]
            ts = datetime(day.year, day.month, day.day, rng.randint(6, 22), rng.randint(0, 59), rng.randint(0, 59))
            status = rng.choices(["fulfilled", "cancelled", "returned"], [0.94, 0.04, 0.02])[0]
            loaded = ts + timedelta(minutes=rng.randint(5, 240))
            customer = f"C{rng.randint(1, 2600):05d}"
            if status == "cancelled" and rng.random() < 0.5:
                # the first load said fulfilled; the cancellation arrived as a later version of the same order
                orders.append({"order_id": order_id, "channel_code": channel, "customer_id": customer,
                               "order_ts": fmt(ts), "order_status": "fulfilled", "loaded_at": fmt(loaded)})
                loaded = loaded + timedelta(days=1, hours=rng.randint(1, 20))
            orders.append({"order_id": order_id, "channel_code": channel, "customer_id": customer,
                           "order_ts": fmt(ts), "order_status": status, "loaded_at": fmt(loaded)})
            n_lines = rng.choices([1, 2, 3], [0.6, 0.3, 0.1])[0]
            for line_no in range(1, n_lines + 1):
                sku = rng.choices(skus, weights)[0]
                qty = rng.choices([1, 2, 3], [0.75, 0.2, 0.05])[0]
                discount = round(qty * price[sku] * 0.10, 2) if rng.random() < 0.15 else 0.0
                line = {"order_id": order_id, "line_no": line_no, "sku": sku, "quantity": qty,
                        "unit_price": f"{price[sku]:.2f}", "discount": f"{discount:.2f}", "loaded_at": fmt(loaded)}
                if rng.random() < 0.02:
                    # the first load carried the wrong quantity; the later version is the truth
                    lines.append(dict(line, quantity=qty + 1))
                    line = dict(line, loaded_at=fmt(loaded + timedelta(days=1, hours=2)))
                lines.append(line)
    return orders, lines


def make_snapshots(rng: random.Random, products, orders, lines):
    # the latest version of each order and line wins, exactly as Silver will decide
    status, channel_of, day_of = {}, {}, {}
    for o in orders:
        status[o["order_id"]] = o["order_status"]
        channel_of[o["order_id"]] = o["channel_code"]
        day_of[o["order_id"]] = o["order_ts"][:10]
    latest = {}
    for ln in lines:
        latest[(ln["order_id"], ln["line_no"])] = ln
    sold = defaultdict(int)
    for (order_id, _), ln in latest.items():
        if status[order_id] != "cancelled":
            sold[(channel_of[order_id], ln["sku"], day_of[order_id])] += ln["quantity"]
    supplies = defaultdict(list)
    for c in CHANNELS:
        if c[3]:
            supplies[c[3]].append(c[0])

    def demand(channel: str, sku: str, day: str) -> int:
        own = sold.get((channel, sku, day), 0)
        downstream = sum(sold.get((t, sku, day), 0) for t in supplies.get(channel, []))
        return own + downstream

    rows = []
    start = AS_OF - timedelta(days=SNAPSHOT_DAYS - 1)
    for c in CHANNELS:
        code, lead, safety_days = c[0], c[5], c[7]
        for p in products:
            sku, case = p["sku"], p["case_size"]
            history = [demand(code, sku, (start - timedelta(days=k)).isoformat()) for k in range(1, 29)]
            velocity = sum(history) / 28.0
            level = int(round(velocity * rng.uniform(12, 70))) + rng.randint(0, 3)
            pending: list[tuple[int, int]] = []
            for d in range(SNAPSHOT_DAYS):
                day = start + timedelta(days=d)
                level += sum(q for a, q in pending if a <= d)
                pending = [(a, q) for a, q in pending if a > d]
                level = max(0, level - demand(code, sku, day.isoformat()))
                if not pending and velocity > 0 and level < velocity * (lead + safety_days) and rng.random() < 0.7:
                    qty = max(case, int(math.ceil(velocity * (lead + 14 + safety_days) / case)) * case)
                    pending.append((d + lead + rng.randint(-2, 4), qty))
                on_order = sum(q for _, q in pending)
                loaded = datetime(day.year, day.month, day.day, 23, 55) + timedelta(minutes=rng.randint(0, 4))
                row = {"snapshot_date": day.isoformat(), "channel_code": code, "sku": sku,
                       "on_hand": level, "on_order": on_order, "loaded_at": fmt(loaded)}
                rows.append(row)
                if rng.random() < 0.01:
                    rows.append(dict(row, loaded_at=fmt(loaded + timedelta(hours=1))))   # delivered twice
    return rows


def render(rows, fields) -> str:
    buf = io.StringIO()
    writer = csv.DictWriter(buf, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    for r in rows:
        writer.writerow({k: (str(r[k]).lower() if isinstance(r[k], bool) else r[k]) for k in fields})
    return buf.getvalue()


def build() -> dict[str, str]:
    rng = random.Random(SEED)
    products, weights = make_products(rng)
    orders, lines = make_orders(rng, products, weights)
    snapshots = make_snapshots(rng, products, orders, lines)
    return {
        "channels.csv": render([dict(zip(CHANNEL_FIELDS, c)) for c in CHANNELS], CHANNEL_FIELDS),
        "products.csv": render(products, PRODUCT_FIELDS),
        "orders.csv": render(orders, ORDER_FIELDS),
        "order_lines.csv": render(lines, LINE_FIELDS),
        "inventory_snapshots.csv": render(snapshots, SNAPSHOT_FIELDS),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true",
                        help="regenerate in memory and fail if the committed seeds differ")
    args = parser.parse_args()
    files = build()
    if args.check:
        drift = [name for name, text in files.items()
                 if not (SEEDS_DIR / name).exists() or (SEEDS_DIR / name).read_text(encoding="utf8") != text]
        if drift:
            print("seeds differ from the generator:", ", ".join(drift))
            return 1
        print("seeds match the generator")
        return 0
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    for name, text in files.items():
        (SEEDS_DIR / name).write_text(text, encoding="utf8", newline="\n")
        print(f"{name}: {text.count(chr(10)) - 1} rows")
    return 0


if __name__ == "__main__":
    sys.exit(main())
