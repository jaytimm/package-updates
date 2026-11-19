# puremoe + textpress Weekly API Health Report – Project Outline

A brief for Claude Code. Goal: a hosted weekly check that runs both of my R packages, puremoe (PubMed and the NIH/NLM stack) and textpress (Hugging Face embeddings and Wikipedia), against their live APIs and publishes one combined, detailed report of every output, so I catch silent breakage, not just errors.

## Context

- puremoe (\[GitHub\](https://github.com/jaytimm/puremoe), \[CRAN\](https://cran.r-project.org/package=puremoe)) is a PMID-centered interface: search\_pubmed() returns PMIDs, then get\_records() pulls from PubMed (metadata and abstracts), NIH iCite (citations), PubTator3 (entity annotations), PMC (full text), and MeSH resources. Each of those services is a separate thing that can break.
- About 600 downloads a month, so real people depend on it.
- NLM often makes small, quiet changes (renamed fields, changed formats, new limits) that can break things without throwing an error.
- I do NOT want anything running on my own machine. Use GitHub Actions on a schedule.

## Step 1: Understand the package

- Read the repo: exported functions, existing tests (if any), and especially the vignettes.
- Use the vignettes as the source of truth for typical usage. Each vignette example becomes a check.
- Summarize for me which functions hit which API endpoints before building anything.

## Step 2: Build the checks

For each vignette example and each exported API-calling function:

- Run it live against the real API with a small, stable query.
- Record: success or error, run time, number of rows/records, column names and types, and a sample of the actual output (first few rows).
- Flag "succeeded but suspicious" results, such as:
  - Zero or unexpectedly few results for a query that normally returns many
  - Missing, renamed, or new columns compared to a saved baseline
  - Columns that are all NA or empty
  - Type changes (e.g. date becoming character)
  - Unusually slow responses or rate-limit warnings
- Save a baseline snapshot of expected structure in the repo so each day can be compared against it.

## Step 2b: TextPress embedding checks

TextPress is a clean, simple NLP package, but it calls a Hugging Face model to build embeddings, and Hugging Face changes its API and model hosting too.

- Read the textpress repo (\[GitHub\](https://github.com/jaytimm/textpress), \[CRAN\](https://cran.r-project.org/package=textpress)) and vignettes the same way as puremoe; vignette examples become checks.
- Embed a few fixed test sentences each run and record:
  - Dimensions: every embedding has the same length as the saved baseline (a change means the model was swapped)
  - Values: numeric, no NA, NaN, or empty vectors
  - Sanity check: two similar sentences score closer to each other than to an unrelated sentence
  - Response time, plus any deprecation or redirect warnings
- Retry once on a cold-start or "model loading" response before calling it a failure.
- Flag model deprecation, moved endpoints, or changes to the free inference API.
- Store the Hugging Face token as a GitHub Secret.

TextPress also fetches web content. There is no search-engine scraping anymore: it is bring-your-own-URL, except for Wikipedia. Check those too:

- Wikipedia functions: a fixed query still returns URLs, and reference fetching still returns references with the expected columns.
- Fetch/read: a small set of stable URLs (e.g. a few Wikipedia articles) still comes back with real article text, not empty strings or boilerplate.
- Local processing (tokenizing, dictionary search): a quick smoke test only, since it doesn't depend on any outside service.

## Step 3: The report

- Generate one combined, detailed HTML report (R Markdown or Quarto) each run, with a section for each package.
- Top section: overall status (all good / warnings / failures) with a one-line summary per check.
- Below that: every check with its full details and sample output, so I can eyeball the real results.
- Include a diff against the baseline whenever structure changed.
- Publish the current report and report history with GitHub Pages.
- Keep the current overall status, one-line results, last successful run date, and a link to the detailed report in this monitoring repository's README.
- Do not modify the README or other files in puremoe, textpress, or any other monitored repository.

## Step 4: Weekly publication

- GitHub Actions workflow on a weekly schedule, e.g. Monday morning (hosted by GitHub, nothing local).
- Also allow running it manually with a button (workflow\_dispatch).
- Update this monitoring repository's README with the latest status summary and report link.
- Create one GitHub Discussion in this monitoring repository for each weekly run, with a status-at-a-glance title such as "Package check: OK" or "Package check: TextPress 1 WARNING" and a link to the full report.
- Store the Hugging Face token and any NCBI API key as GitHub Secrets. Walk me through setting those up.
- Optional: also open a GitHub issue automatically when something fails.

## Step 4b: Extras for the weekly report

- Keep-alive: GitHub disables scheduled workflows after 60 days of no repo activity. Prevent that (e.g. a keepalive step), and show the last successful run date in the README and weekly Discussion.
- CRAN check results: pull each package's CRAN check status across platforms into the report, since failures there can get a package archived.
- Download stats: use cranlogs to add weekly downloads per package, with a simple trend.

## Step 5: Hand-off

- Explain in plain language what was built and where the files live.
- Tell me how to update the baseline when NLM makes an intentional change I've adapted to.
- Keep it low-maintenance. I want to glance at the central README or weekly Discussion, not babysit a system.

## Prompt to paste into Claude Code

"Read my puremoe (github.com/jaytimm/puremoe) and textpress (github.com/jaytimm/textpress) R package repos, including the vignettes. Build a GitHub Actions workflow that runs weekly. It should execute the vignette examples and API-calling functions against the live services (puremoe: PubMed, iCite, PubTator3, PMC, MeSH; one check per get\_records() endpoint) and the Hugging Face embedding model (TextPress), compare output structure to a saved baseline, and publish one combined, detailed HTML report with every output to GitHub Pages. Update only this monitoring repository's README with the current summary and create a weekly Discussion linking to the full report; do not modify the monitored package repositories. Flag results that succeed but look wrong (empty, renamed columns, type changes, all-NA, changed embedding dimensions, failed similarity sanity check). Retry once on Hugging Face cold starts. Nothing should run on my local machine. Start by summarizing the functions and endpoints, then follow the outline in this doc."

## Later idea: local news RSS/RAG project

Not for now. There's also a local RAG/RSS project on my GitHub that pulls from local news sources. It could join the weekly report later:

- For each feed: does it still resolve, and does it return fresh items?
- Track feeds that redirect, change URLs, go stale, or start returning junk or paywalled content.
- Keep a running tally of how many sources stay consistent week to week versus how many drift.
