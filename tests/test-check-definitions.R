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

definition <- definitions[[match("puremoe_local_smoke", ids)]]
result <- monitor_run_check(
  definition$id, definition$package, definition$code,
  definition$expectations, definition$validator %||% NULL,
  baseline_dir = NULL
)
stopifnot(identical(result$status, "ok"))

sentences <- data.frame(
  doc_id = c(1L, 1L), sentence_id = c("1", "2"),
  text = c("Dr. Smith's well-known work. ", "They've re-tested it."),
  stringsAsFactors = FALSE
)
tokens <- data.frame(
  id = c(rep("1.1", 7L), rep("1.2", 5L)),
  token = c(
    "Dr", ".", "Smith", "'s", "well-known", "work", ".",
    "They", "'ve", "re-tested", "it", "."
  ),
  start = c(1L, 3L, 5L, 10L, 13L, 24L, 28L, 1L, 5L, 9L, 19L, 21L),
  end = c(2L, 3L, 9L, 11L, 22L, 27L, 28L, 4L, 7L, 17L, 20L, 21L),
  stringsAsFactors = FALSE
)
valid_local_output <- list(sentences = sentences, tokens = tokens)
stopifnot(nrow(monitor_textpress_local_validator(valid_local_output)) == 0L)
invalid_local_output <- valid_local_output
invalid_local_output$tokens$start[invalid_local_output$tokens$token == "well-known"] <- 14L
stopifnot("biber_source_spans" %in%
            monitor_textpress_local_validator(invalid_local_output)$code)

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
