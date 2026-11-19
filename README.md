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

See [plans.md](plans.md) for the project outline.

## Status

Planning and package/API inventory.
