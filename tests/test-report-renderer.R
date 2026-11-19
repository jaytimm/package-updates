source("R/check-runner.R")
source("R/report-renderer.R")

test_dir <- tempfile("report-renderer-")
dir.create(test_dir)
on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)
results_dir <- file.path(test_dir, "results")
reports_dir <- file.path(test_dir, "reports")
dir.create(results_dir)

ok <- monitor_run_check(
  "puremoe_fixture", "puremoe",
  function() data.frame(pmid = "1", title = "Example"),
  baseline_dir = NULL
)
ok$kind <- "local"
ok$package_version <- "1.0.0"
monitor_write_result(ok, results_dir)

failure <- monitor_run_check(
  "textpress_fixture", "textpress",
  function() stop("upstream unavailable"),
  baseline_dir = NULL
)
failure$kind <- "live"
failure$package_version <- "1.0.0"
monitor_write_result(failure, results_dir)

readme <- file.path(test_dir, "README.md")
writeLines(c("# Test", "", "Body"), readme)
rendered <- monitor_render_reports(results_dir, reports_dir, readme)

stopifnot(identical(rendered$overall, "failure"))
stopifnot(file.exists(rendered$latest), file.exists(rendered$history))
latest <- readLines(rendered$latest, warn = FALSE)
stopifnot(any(grepl("Overall: .*FAILURE", latest)))
stopifnot(any(grepl("puremoe_fixture", latest, fixed = TRUE)))
stopifnot(any(grepl("upstream unavailable", latest, fixed = TRUE)))
readme_lines <- readLines(readme, warn = FALSE)
stopifnot(any(readme_lines == "<!-- package-monitor-status:start -->"))
stopifnot(any(grepl("View the full GitHub-rendered report", readme_lines, fixed = TRUE)))

# Re-rendering replaces the status block without trailing NA values or duplicate
# markers.
invisible(monitor_render_reports(results_dir, reports_dir, readme))
readme_lines <- readLines(readme, warn = FALSE)
stopifnot(sum(readme_lines == "<!-- package-monitor-status:start -->") == 1L)
stopifnot(sum(readme_lines == "<!-- package-monitor-status:end -->") == 1L)
stopifnot(!any(is.na(readme_lines) | readme_lines == "NA"))

cat("report-renderer tests passed\n")
