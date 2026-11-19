source("R/check-runner.R")

test_dir <- tempfile("monitor-tests-")
dir.create(test_dir)
on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)

expect_status <- function(result, status) {
  stopifnot(identical(result$status, status))
}

good <- function(extra = FALSE, numeric_as_character = FALSE) {
  value <- data.frame(
    pmid = c("1", "2"),
    year = if (numeric_as_character) c("2025", "2026") else c(2025L, 2026L),
    title = c("One", "Two"),
    stringsAsFactors = FALSE
  )
  if (extra) value$new_column <- TRUE
  value
}

expectations <- list(list(
  kind = "data.frame",
  min_rows = 1L,
  required_columns = c("pmid", "year", "title"),
  nonempty_columns = c("pmid", "title")
))

initial <- monitor_run_check(
  "fixture", "test", good, expectations,
  baseline_dir = NULL
)
expect_status(initial, "ok")
stopifnot(nrow(initial$schema) == 4L)

monitor_write_baseline(initial, test_dir)
unchanged <- monitor_run_check("fixture", "test", good, expectations, baseline_dir = test_dir)
expect_status(unchanged, "ok")

added <- monitor_run_check(
  "fixture", "test", function() good(extra = TRUE), expectations,
  baseline_dir = test_dir
)
expect_status(added, "warning")
stopifnot("structure_added" %in% added$issues$code)

removed <- monitor_run_check(
  "fixture", "test", function() good()[, c("pmid", "year")], expectations,
  baseline_dir = test_dir
)
expect_status(removed, "failure")
stopifnot("missing_required_columns" %in% removed$issues$code)
stopifnot("structure_removed" %in% removed$issues$code)

changed <- monitor_run_check(
  "fixture", "test", function() good(numeric_as_character = TRUE), expectations,
  baseline_dir = test_dir
)
expect_status(changed, "failure")
stopifnot("type_changed" %in% changed$issues$code)

empty <- monitor_run_check(
  "empty", "test", function() data.frame(value = character()),
  list(list(kind = "data.frame", min_rows = 1L)), baseline_dir = NULL
)
expect_status(empty, "warning")
stopifnot("too_few_rows" %in% empty$issues$code)

missing_values <- monitor_run_check(
  "missing", "test", function() data.frame(value = c(NA_character_, "")),
  list(list(nonempty_columns = "value")), baseline_dir = NULL
)
expect_status(missing_values, "warning")
stopifnot("all_missing_column" %in% missing_values$issues$code)

non_finite <- monitor_run_check(
  "embedding", "test", function() matrix(c(1, NaN), nrow = 1L),
  list(list(kind = "matrix", finite = TRUE)), baseline_dir = NULL
)
expect_status(non_finite, "failure")

matrix_result <- monitor_run_check(
  "matrix", "test", function() matrix(1:6, nrow = 2L),
  list(list(kind = "matrix", finite = TRUE)), baseline_dir = NULL
)
monitor_write_baseline(matrix_result, test_dir)
matrix_changed <- monitor_run_check(
  "matrix", "test", function() matrix(1:8, nrow = 2L),
  list(list(kind = "matrix", finite = TRUE)), baseline_dir = test_dir
)
expect_status(matrix_changed, "failure")
stopifnot("matrix_width_changed" %in% matrix_changed$issues$code)

warned <- monitor_run_check(
  "warning", "test", function() { warning("upstream warning"); 1L },
  baseline_dir = NULL
)
expect_status(warned, "warning")
stopifnot(identical(warned$warnings, "upstream warning"))

failed <- monitor_run_check(
  "failure", "test", function() stop("service unavailable"),
  baseline_dir = NULL
)
expect_status(failed, "failure")
stopifnot(identical(failed$error, "service unavailable"))

custom <- monitor_run_check(
  "custom", "test", function() 1L,
  validator = function(output) monitor_issue(
    "warning", "sanity_check", "root", "Synthetic sanity warning."
  ),
  baseline_dir = NULL
)
expect_status(custom, "warning")

result_path <- monitor_write_result(unchanged, test_dir)
stopifnot(file.exists(result_path))
roundtrip <- jsonlite::read_json(result_path, simplifyVector = TRUE)
stopifnot(identical(roundtrip$id, "fixture"))

summary <- monitor_summarize(list(unchanged, added, failed))
stopifnot(nrow(summary) == 3L)
stopifnot(identical(summary$status, c("ok", "warning", "failure")))

cat("check-runner tests passed\n")
