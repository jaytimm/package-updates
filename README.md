# Package API Health Reports

Automated weekly health checks for the
[`puremoe`](https://github.com/jaytimm/puremoe) and
[`textpress`](https://github.com/jaytimm/textpress) R packages.

The project will run live API checks in GitHub Actions, compare results with
saved structural baselines, and publish one detailed HTML report covering both
packages. This README will show the latest summary, GitHub Pages will retain
the full report history, and a weekly Discussion will link to each new report.
Reports will highlight errors as well as suspicious successful responses, such
as empty results, schema changes, type changes, and invalid embeddings.

All reporting stays in this monitoring repository. The monitored package
repositories and their READMEs are not modified.

See [plans.md](plans.md) for the project outline and
[docs/api-inventory.md](docs/api-inventory.md) for the function-to-service map.
The [runner contract](docs/check-runner.md) documents result and validation
semantics.

## Status

Package/API inventory and the reusable check runner are complete. Live check
definitions and report rendering are next.

## Check runner

`R/check-runner.R` provides a common result schema for every live and local
check. It captures errors and warnings, records timing, inspects output
structure, applies suspicious-success rules, compares tracked baselines, and
writes JSON results for reporting.

Structural baselines live in `baselines/` and are never updated by a scheduled
run. After reviewing an intentional change, update one explicitly with:

```sh
Rscript scripts/update-baseline.R results/CHECK_ID.json baselines --yes
```

Run the deterministic runner tests with:

```sh
Rscript tests/test-check-runner.R
```
