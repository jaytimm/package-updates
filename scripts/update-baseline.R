args <- commandArgs(trailingOnly = TRUE)

usage <- paste(
  "Usage:",
  "Rscript scripts/update-baseline.R RESULTS_JSON [BASELINE_DIR] --yes"
)

if (!length(args) || !"--yes" %in% args) {
  stop(usage, call. = FALSE)
}

args <- setdiff(args, "--yes")
if (!length(args)) stop(usage, call. = FALSE)

result_path <- args[[1L]]
baseline_dir <- if (length(args) >= 2L) args[[2L]] else "baselines"
if (!file.exists(result_path)) stop("Result file does not exist: ", result_path, call. = FALSE)

source("R/check-runner.R")
result <- jsonlite::read_json(result_path, simplifyVector = TRUE)

if (identical(result$status, "failure") || is.null(result$schema)) {
  stop("Refusing to baseline a failed result or a result without a schema.", call. = FALSE)
}

path <- monitor_write_baseline(result, baseline_dir)
message("Baseline updated after explicit approval: ", path)
