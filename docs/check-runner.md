# Check runner contract

Every check calls `monitor_run_check()` with a stable ID, package name, function
that returns the value to inspect, declarative expectations, and optionally a
custom validator.

The returned result contains:

| Field | Meaning |
| --- | --- |
| `schema_version` | Result-contract version |
| `id`, `package` | Stable identity and report grouping |
| `status` | `ok`, `warning`, or `failure` |
| `started_at`, `finished_at`, `elapsed_seconds` | UTC timing data |
| `warnings`, `error` | Captured R conditions |
| `issues` | Machine-readable suspicious-success and baseline findings |
| `schema` | Flattened output structure used for baseline comparison |
| `sample` | Small bounded sample for the detailed report |

Declarative expectations support:

- output kind (`data.frame`, `matrix`, `list`, or `vector`);
- minimum row/item count;
- required columns;
- columns that must not be entirely missing or empty;
- finite numeric values;
- exact table/matrix width where it is an API contract;
- slow-response warning thresholds;
- nested paths such as `entities` and `relations`.

Custom validators return `monitor_issue()` rows. They cover semantic rules that
cannot be expressed structurally, such as embedding-similarity ordering.

Status precedence is `failure` over `warning` over `ok`. A thrown error, failed
structural contract, non-finite embedding, or failed custom invariant produces
`failure`. Captured warnings, new fields, low-but-nonzero results, all-missing
columns, slow responses, or a missing baseline produce `warning`.
