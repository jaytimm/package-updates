source("R/check-runner.R")
source("R/report-renderer.R")

args <- commandArgs(trailingOnly = TRUE)
option <- function(name, default) {
  hit <- grep(paste0("^--", name, "="), args, value = TRUE)
  if (!length(hit)) default else sub(paste0("^--", name, "="), "", hit[[1L]])
}

output <- monitor_render_reports(
  results_dir = option("results-dir", "results"),
  reports_dir = option("reports-dir", "reports"),
  readme = option("readme", "README.md")
)

message("Latest report: ", output$latest)
message("History report: ", output$history)
message("Overall status: ", toupper(output$overall))
