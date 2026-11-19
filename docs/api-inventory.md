# Package and API inventory

This inventory is the implementation contract for the monitoring checks. It
was prepared from clean, temporary clones of the public repositories; no files
in the monitored repositories were changed.

Source revisions inspected:

- `puremoe`: `f660ffd61e8fba17f2eaceae9a7fed4e399eb1f8`
- `textpress`: `a42c2056cc463a2fce23e2b3595121ead5c07863`
- `local-rags-rss` (future scope): `228e55f79de7f5caaf1d5d6aff0bb84815f3c3f2`

## puremoe

### Live-service functions

| Exported function | Service or resource | Request path | Expected result |
| --- | --- | --- | --- |
| `search_pubmed()` | NCBI PubMed E-utilities through `rentrez` | PubMed `esearch` | Character/numeric PMID vector |
| `get_records(..., "pubmed_abstracts")` | NCBI PubMed E-utilities through `rentrez` | PubMed `efetch`, XML | Article-level table with metadata, abstract, and annotation list-column |
| `get_records(..., "pubmed_affiliations")` | NCBI PubMed E-utilities through `rentrez` | PubMed `efetch`, XML | Author-affiliation rows |
| `get_records(..., "icites")` | NIH iCite | `https://icite.od.nih.gov/api/pubs?pmids=...` | Citation metrics and citation-network list-columns |
| `get_records(..., "pubtator")` | NCBI PubTator3 | `/research/pubtator3-api/publications/export/biocjson?pmids=...` | List containing entity and relation tables |
| `pmid_to_pmc()` | NCBI PMC ID Converter | `/pmc/utils/idconv/v1.0/` | PMID, PMCID, and DOI table |
| `pmid_to_ftp()` | NCBI PMC ID Converter and PMC OA data on AWS | ID Converter, then `pmc-oa-opendata.s3.amazonaws.com` | PMID/PMCID/DOI and open-access XML URL |
| `get_records(..., "pmc_fulltext")` | PMC OA data on AWS | Direct XML URLs returned by `pmid_to_ftp()` | Section-level full text |
| `data_mesh_thesaurus()` | `jaytimm/mesh-builds` GitHub data files | Descriptor and supplementary-concept RDS downloads | Combined MeSH thesaurus table |
| `data_mesh_trees()` | `jaytimm/mesh-builds` GitHub data file | MeSH tree RDS download | MeSH tree table |

`pubtations` is a legacy alias for `pubtator`, not a separate service.

### Local-only exports

These should receive fast smoke tests but do not need live-service health
checks:

- `endpoint_info()`
- `citation_network()` and `citation_snowball()`
- `mesh_keyness()`
- `pubtator_context()`, `pubtator_cooccurrence()`, and `pubtator_network()`
- bundled `data_mesh_frequencies` data

### Vignette coverage

- `getting-started.Rmd`: PubMed search; abstracts; affiliations; iCite;
  PubTator; PMID-to-PMC/OA resolution; PMC full text; endpoint metadata.
- `mesh-search.Rmd`: downloaded MeSH thesaurus and trees; bundled frequency
  data.
- `citation-snowball.Rmd`: PubMed, iCite, citation expansion, PubMed metadata,
  and local MeSH keyness.
- `pubtator-context.Rmd`: PubMed search, PubTator entities/relations, and local
  context/co-occurrence/network transformations.

The health suite should use small stable fixtures derived from these examples,
not execute the full vignettes verbatim. The vignettes contain broad searches,
large result sets, display widgets, and examples whose output naturally changes.

## textpress

### Live-service functions

| Exported function | Service or resource | Request path | Expected result |
| --- | --- | --- | --- |
| `fetch_rss()` | Arbitrary RSS/Atom publishers | User-supplied feed URLs | Article discovery table with feed and article metadata |
| `fetch_wiki_urls()` | English Wikipedia MediaWiki API | `https://en.wikipedia.org/w/api.php` | Wikipedia article URL vector |
| `fetch_wiki_refs()` | English Wikipedia article HTML | Article pages and `cite_note` elements | Source URL, reference ID, and external reference URL table |
| `read_urls()` | Arbitrary web pages, with Wikipedia-specific parsing | User-supplied HTTP(S) URLs | `text` and `meta` tables containing real article nodes and metadata |
| `util_fetch_embeddings()` | Hugging Face Inference API | `router.huggingface.co/hf-inference/models/BAAI/bge-small-en-v1.5` | Numeric embedding matrix with stable row identifiers |

### Local-only exports

These should be exercised with deterministic fixtures and no network:

- `abbreviations`
- `nlp_split_paragraphs()`, `nlp_split_sentences()`, `nlp_tokenize_text()`,
  `nlp_cast_tokens()`, `nlp_roll_chunks()`, and `nlp_index_tokens()`
- `search_regex()`, `search_dict()`, `search_index()`, and `search_vector()`
- bundled dictionaries and feed catalogs

### Vignette coverage

- `wiki-data.Rmd`: Wikipedia search, reference extraction, and page reading.
- `web-data.Rmd`: RSS discovery and article reading.
- `basic-nlp.Rmd`: Wikipedia discovery/reading followed by local NLP.
- `dict-search.Rmd` and `regex-search.Rmd`: RSS/HTML acquisition followed by
  deterministic local search.
- `semantic-search.Rmd`: RSS/HTML acquisition, chunking, Hugging Face
  embeddings, BM25, vector search, and reciprocal-rank fusion. The optional LLM
  example is not part of package health monitoring.

The embedding check must retry once for model startup, require a numeric matrix
with no non-finite values, compare its dimension with the baseline, and verify
that two similar fixed sentences are closer than either is to an unrelated
sentence.

## Proposed check groups

Each live check records status, elapsed time, warnings, row count, column names,
column classes, empty/all-missing columns, and a small sanitized output sample.

1. `puremoe_pubmed_search`
2. `puremoe_pubmed_abstracts`
3. `puremoe_pubmed_affiliations`
4. `puremoe_icite`
5. `puremoe_pubtator`
6. `puremoe_pmc_id_converter`
7. `puremoe_pmc_oa_url`
8. `puremoe_pmc_fulltext`
9. `puremoe_mesh_thesaurus`
10. `puremoe_mesh_trees`
11. `puremoe_local_smoke`
12. `textpress_rss`
13. `textpress_wikipedia_search`
14. `textpress_wikipedia_references`
15. `textpress_read_urls`
16. `textpress_huggingface_embeddings`
17. `textpress_local_smoke`

Exact row counts should generally be minimum thresholds rather than exact
baselines. Structural baselines should distinguish required columns from
allowed additions so a harmless upstream column addition becomes a warning,
not an opaque failure.

## local-rags-rss: deferred scope

The repository is named `jaytimm/local-rags-rss` (plural `rags`). It is a data
pipeline rather than an R package. Its relevant external boundaries are:

- the 3DLNews snapshot hosted on `raw.githubusercontent.com`;
- the published set of roughly 1,600 RSS/Atom feeds;
- publisher homepages used for feed autodiscovery;
- optional OpenAI review, which is a maintenance aid rather than a health
  check.

When this project joins the monitor, use its existing `check-feed-rot.R` flow
instead of duplicating feed-validation logic. Report usable, stale, redirected,
transiently failed, persistently failed, and replacement-candidate counts. It
remains out of the first implementation phase, as specified in `plans.md`.

