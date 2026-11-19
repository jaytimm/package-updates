# Structural baselines

Each check receives one tracked JSON baseline named `CHECK_ID.json`. A baseline
contains only structure—not live records, credentials, tokens, or full API
responses.

The stored fields are:

- `schema_version`: baseline format version;
- `check_id`: stable check identifier;
- `created_at`: UTC approval time;
- `schema`: output paths, object kinds, R classes, and matrix width.

Comparison policy:

- removed fields/components: failure;
- R class or object-kind changes: failure;
- changed matrix width: failure;
- new fields/components: warning;
- row counts and content expectations: handled by the check specification, not
  frozen into the structural baseline.

Scheduled workflows must never update baselines. After reviewing an intentional
upstream or package change, use the explicit command documented in the project
README and commit the resulting JSON diff.
