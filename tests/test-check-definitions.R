source("R/check-runner.R")
source("R/check-definitions.R")

# Match scripts/run-checks.R: load package namespaces before warning capture so
# host-specific package startup diagnostics are not attributed to a check.
stopifnot(requireNamespace("puremoe", quietly = TRUE))
stopifnot(requireNamespace("textpress", quietly = TRUE))

definitions <- monitor_check_definitions()
ids <- vapply(definitions, `[[`, character(1L), "id")
stopifnot(length(definitions) == 17L)
stopifnot(!anyDuplicated(ids))
stopifnot(all(grepl("^[a-z0-9_]+$", ids)))
stopifnot(all(vapply(definitions, function(x) x$package %in% c("puremoe", "textpress"), logical(1L))))
stopifnot(all(vapply(definitions, function(x) x$kind %in% c("live", "local"), logical(1L))))
stopifnot(all(vapply(definitions, function(x) is.function(x$code), logical(1L))))

for (id in c("puremoe_local_smoke", "textpress_local_smoke")) {
  definition <- definitions[[match(id, ids)]]
  result <- monitor_run_check(
    definition$id, definition$package, definition$code,
    definition$expectations, definition$validator %||% NULL,
    baseline_dir = NULL
  )
  stopifnot(identical(result$status, "ok"))
}

good_embeddings <- rbind(
  similar_a = c(1, 0),
  similar_b = c(0.9, 0.1),
  unrelated = c(0, 1)
)
stopifnot(is.null(monitor_embedding_validator(good_embeddings)))
bad_embeddings <- rbind(
  similar_a = c(1, 0),
  similar_b = c(0, 1),
  unrelated = c(1, 0)
)
stopifnot(identical(monitor_embedding_validator(bad_embeddings)$code, "embedding_similarity"))

cat("check-definition tests passed\n")
