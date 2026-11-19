# Live check definitions

The suite currently contains 17 checks: 11 for `puremoe` and 6 for
`textpress`. Every request uses a small fixture and one worker to minimize load
on upstream services.

## Fixtures

- PubMed search: doxorubicin and cardiotoxicity, capped at 20 PMIDs.
- PubMed/iCite/PubTator records: PMIDs `38136652` and `11250746`.
- PMC conversion and full text: PMIDs `11250746` and `11573492`.
- Wikipedia: the Doxorubicin article and a three-result API search.
- RSS: the POLITICO Congress feed from the bundled `textpress` catalog.
- Embeddings: two semantically similar cat sentences and one unrelated markets
  sentence.
- Local TextPress semantics: `Dr.` must not create a false sentence boundary;
  Biber punctuation and contraction suffixes remain separate tokens;
  intra-word hyphens remain intact; and token spans must address the original
  sentence text.

`NCBI_API_KEY` is optional. `HUGGINGFACE_API_TOKEN` is required for the
embedding check. Neither value is written to results, samples, or baselines.

## Initial live probe

The first complete probe ran on 2026-11-19 against locally installed
`puremoe` 1.1.1 and `textpress` 1.1.2.

- 15 checks satisfied their content contracts and received reviewed structural
  baselines.
- PubMed, iCite, PubTator, PMC conversion/OA/full text, MeSH trees, RSS,
  Wikipedia, web reading, and both local smoke suites returned expected output.
- `puremoe_mesh_thesaurus` failed twice while downloading/reading the two
  GitHub-hosted RDS artifacts (`error reading from connection`). The check uses
  a forced clean download and one retry; it remains a failure rather than being
  hidden.
- `textpress_huggingface_embeddings` returned HTTP 402 stating that prepaid
  inference credits are required. It remains a failure and has no baseline.

The two failed checks intentionally have no baseline. A baseline should be
created only after the service succeeds and its output has been reviewed.

## Running checks

Run the complete suite:

```sh
Rscript scripts/run-checks.R
```

Run selected checks:

```sh
Rscript scripts/run-checks.R \
  --checks=puremoe_pubtator,textpress_read_urls
```

The command exits nonzero when any check fails. `--allow-failures` is available
for diagnostic runs that must collect every result before returning.
