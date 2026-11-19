source("R/check-runner.R")
source("R/check-definitions.R")

args <- commandArgs(trailingOnly = TRUE)
option <- function(name, default = NULL) {
  hit <- grep(paste0("^--", name, "="), args, value = TRUE)
  if (!length(hit)) default else sub(paste0("^--", name, "="), "", hit[[1L]])
}

results_dir <- option("results-dir", "results")
baseline_dir <- option("baseline-dir", "baselines")
selected_checks <- option("checks")
selected_packages <- option("packages")
allow_failures <- "--allow-failures" %in% args

if (!is.null(selected_checks)) selected_checks <- strsplit(selected_checks, ",", fixed = TRUE)[[1L]]
if (!is.null(selected_packages)) selected_packages <- strsplit(selected_packages, ",", fixed = TRUE)[[1L]]

definitions <- monitor_check_definitions()
if (!is.null(selected_checks)) {
  unknown <- setdiff(selected_checks, vapply(definitions, `[[`, character(1L), "id"))
  if (length(unknown)) stop("Unknown checks: ", paste(unknown, collapse = ", "), call. = FALSE)
  definitions <- Filter(function(x) x$id %in% selected_checks, definitions)
}
if (!is.null(selected_packages)) {
  definitions <- Filter(function(x) x$package %in% selected_packages, definitions)
}
if (!length(definitions)) stop("No checks selected.", call. = FALSE)

required_packages <- unique(vapply(definitions, `[[`, character(1L), "package"))
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1L), quietly = TRUE)]
if (length(missing_packages)) {
  stop("Required packages are not installed: ", paste(missing_packages, collapse = ", "), call. = FALSE)
}

dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
results <- vector("list", length(definitions))

for (i in seq_along(definitions)) {
  definition <- definitions[[i]]
  message(sprintf("[%d/%d] %s", i, length(definitions), definition$id))
  result <- monitor_run_check(
    id = definition$id,
    package = definition$package,
    code = definition$code,
    expectations = definition$expectations %||% list(),
    validator = definition$validator %||% NULL,
    baseline_dir = baseline_dir
  )
  result$kind <- definition$kind
  result$package_version <- as.character(utils::packageVersion(definition$package))
  monitor_write_result(result, results_dir)
  results[[i]] <- result
  message(sprintf("      %s (%.3fs, %d issues)", toupper(result$status), result$elapsed_seconds, nrow(result$issues)))
}

summary <- monitor_summarize(results)
utils::write.table(
  summary, file.path(results_dir, "summary.tsv"), sep = "\t",
  row.names = FALSE, quote = FALSE, na = ""
)
jsonlite::write_json(
  list(
    generated_at = monitor_now(),
    overall_status = if (any(summary$status == "failure")) "failure" else if (any(summary$status == "warning")) "warning" else "ok",
    checks = summary
  ),
  file.path(results_dir, "summary.json"),
  pretty = TRUE, auto_unbox = TRUE, na = "null"
)

print(summary, row.names = FALSE)
if (!allow_failures && any(summary$status == "failure")) quit(status = 1L)
