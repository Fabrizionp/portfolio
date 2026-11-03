# Changelog

All notable changes to this portfolio. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the versions follow [Semantic Versioning](https://semver.org/): a new case study or practice is a minor
version, a correction is a patch.

## [1.2.2] · 2026-11-03

### Changed
- The checks rerun when a pull request title is edited.

## [1.2.1] · 2026-11-02

### Fixed
- `LICENSE` is plain MIT so GitHub detects it; the content license note lives in the README and in `LICENSE-CC-BY-4.0.txt`.

## [1.2.0] · 2026-11-02

### Added
- `tools/`: link check, Mermaid parse-and-render check, demo render check (the same three checks a reader would run).
- GitHub Actions `checks` workflow on every pull request and on `main`, with a Conventional Commits title check.
- MIT license for the code and CC BY 4.0 for the written content and diagrams.
- This changelog, and tags for the earlier versions.

## [1.1.1] · 2026-11-02

### Changed
- README opens with production platforms and data products; roadmap phase 4 adds a Kafka to Iceberg micro-stream.

## [1.1.0] · 2026-11-02

### Changed
- Every case study reviewed against its repository and deepened by mechanism (problem, decision, mechanism, proof).
- CS-05 rewritten around signals that trigger ingestion in layers.
- The agentic delivery playbook rewritten as spec-driven and human-guided: nine stages, risk tiers, Definitions of
  Ready and Done, a RACI table, sources.
- The Power BI demo rebuilt in the design language of a production sales dashboard, with a customer map.
- All diagrams redrawn in one shared style; the three demo pages made to reconcile their own totals.

### Removed
- The job-fit matrix (it named employers and verdicts).

## [1.0.0] · 2026-11-02

### Added
- The hub: seven case studies, two practice documents, the reference-stack roadmap, three synthetic-data demos
  and their screenshots.

[1.2.2]: https://github.com/Fabrizionp/portfolio/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Fabrizionp/portfolio/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/Fabrizionp/portfolio/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/Fabrizionp/portfolio/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/Fabrizionp/portfolio/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Fabrizionp/portfolio/releases/tag/v1.0.0
