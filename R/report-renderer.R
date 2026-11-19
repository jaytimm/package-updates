monitor_markdown_escape <- function(x) {
  x <- as.character(x %||% "")
  x <- gsub("\\|", "\\\\|", x)
  gsub("[\r\n]+", " ", x)
}

monitor_status_label <- function(status) {
  switch(
    status,
    ok = "OK",
    warning = "WARNING",
    failure = "FAILURE",
    toupper(status)
  )
}

monitor_status_icon <- function(status) {
  switch(status, ok = "✅", warning = "⚠️", failure = "❌", "•")
}

monitor_result_files <- function(results_dir) {
  files <- list.files(results_dir, pattern = "[.]json$", full.names = TRUE)
  files[basename(files) != "summary.json"]
}

monitor_read_results <- function(results_dir) {
  files <- monitor_result_files(results_dir)
  if (!length(files)) stop("No individual result JSON files found in ", results_dir, call. = FALSE)
  results <- lapply(files, jsonlite::read_json, simplifyVector = TRUE)
  results <- Filter(function(x) !is.null(x$id) && !is.null(x$status), results)
  if (!length(results)) stop("No valid check results found in ", results_dir, call. = FALSE)
  order_ids <- c(
    "puremoe_pubmed_search", "puremoe_pubmed_abstracts",
    "puremoe_pubmed_affiliations", "puremoe_icite", "puremoe_pubtator",
    "puremoe_pmc_id_converter", "puremoe_pmc_oa_url",
    "puremoe_pmc_fulltext", "puremoe_mesh_thesaurus",
    "puremoe_mesh_trees", "puremoe_local_smoke", "textpress_rss",
    "textpress_wikipedia_search", "textpress_wikipedia_references",
    "textpress_read_urls", "textpress_huggingface_embeddings",
    "textpress_local_smoke"
  )
  ids <- vapply(results, `[[`, character(1L), "id")
  results[order(match(ids, order_ids), ids, na.last = TRUE)]
}

monitor_overall_status <- function(results) {
  statuses <- vapply(results, `[[`, character(1L), "status")
  if (any(statuses == "failure")) "failure" else if (any(statuses == "warning")) "warning" else "ok"
}

monitor_report_time <- function(results) {
  times <- vapply(results, function(x) x$finished_at %||% x$started_at %||% NA_character_, character(1L))
  times <- times[!is.na(times) & nzchar(times)]
  if (!length(times)) monitor_now() else max(times)
}

monitor_issue_rows <- function(issues) {
  if (is.null(issues) || !length(issues)) return(NULL)
  if (is.data.frame(issues)) return(issues)
  tryCatch(as.data.frame(issues, stringsAsFactors = FALSE), error = function(error) NULL)
}

monitor_summary_lines <- function(results) {
  lines <- c(
    "| Package | Check | Status | Seconds | Findings |",
    "| --- | --- | --- | ---: | ---: |"
  )
  for (result in results) {
    issues <- monitor_issue_rows(result$issues)
    issue_count <- if (is.null(issues)) 0L else nrow(issues)
    warning_count <- length(result$warnings %||% character())
    findings <- issue_count + warning_count + as.integer(!is.null(result$error))
    lines <- c(lines, sprintf(
      "| %s | `%s` | %s %s | %.3f | %d |",
      monitor_markdown_escape(result$package),
      monitor_markdown_escape(result$id),
      monitor_status_icon(result$status),
      monitor_status_label(result$status),
      as.numeric(result$elapsed_seconds %||% 0),
      findings
    ))
  }
  lines
}

monitor_json_block <- function(x) {
  if (is.null(x) || !length(x)) return(c("_No sample available._"))
  json <- jsonlite::toJSON(
    x, pretty = TRUE, auto_unbox = TRUE, na = "null", null = "null"
  )
  c("```json", strsplit(json, "\n", fixed = TRUE)[[1L]], "```")
}

monitor_detail_lines <- function(result) {
  issues <- monitor_issue_rows(result$issues)
  warnings <- as.character(result$warnings %||% character())
  lines <- c(
    sprintf("### %s %s", monitor_status_icon(result$status), result$id),
    "",
    sprintf("- Status: **%s**", monitor_status_label(result$status)),
    sprintf("- Package: `%s`%s", result$package,
            if (!is.null(result$package_version)) paste0(" `", result$package_version, "`") else ""),
    sprintf("- Kind: `%s`", result$kind %||% "unknown"),
    sprintf("- Elapsed: `%.3f` seconds", as.numeric(result$elapsed_seconds %||% 0)),
    sprintf("- Finished: `%s`", result$finished_at %||% "unknown")
  )

  if (!is.null(result$error)) {
    lines <- c(lines, "", "#### Error", "", paste0("`", gsub("`", "'", result$error), "`"))
  }
  if (length(warnings)) {
    lines <- c(lines, "", "#### Runtime warnings", "")
    lines <- c(lines, paste0("- ", monitor_markdown_escape(warnings)))
  }
  if (!is.null(issues) && nrow(issues)) {
    lines <- c(
      lines, "", "#### Findings", "",
      "| Severity | Code | Path | Message |",
      "| --- | --- | --- | --- |"
    )
    for (i in seq_len(nrow(issues))) {
      lines <- c(lines, sprintf(
        "| %s | `%s` | `%s` | %s |",
        monitor_markdown_escape(issues$severity[[i]]),
        monitor_markdown_escape(issues$code[[i]]),
        monitor_markdown_escape(issues$path[[i]]),
        monitor_markdown_escape(issues$message[[i]])
      ))
    }
  }

  c(lines, "", "#### Output sample", "", monitor_json_block(result$sample), "")
}

monitor_report_lines <- function(results) {
  overall <- monitor_overall_status(results)
  generated_at <- monitor_report_time(results)
  lines <- c(
    "# Package health report",
    "",
    sprintf("**Overall: %s %s**", monitor_status_icon(overall), monitor_status_label(overall)),
    "",
    sprintf("Generated from the latest completed checks at `%s`.", generated_at),
    "",
    "## Summary",
    "",
    monitor_summary_lines(results)
  )
  for (package in unique(vapply(results, `[[`, character(1L), "package"))) {
    lines <- c(lines, "", sprintf("## %s", package), "")
    package_results <- Filter(function(x) identical(x$package, package), results)
    for (result in package_results) lines <- c(lines, monitor_detail_lines(result))
  }
  c(lines, "", "---", "", "Generated by the central package monitoring repository.")
}

monitor_readme_status_lines <- function(results) {
  overall <- monitor_overall_status(results)
  generated_at <- monitor_report_time(results)
  counts <- table(factor(
    vapply(results, `[[`, character(1L), "status"),
    levels = c("ok", "warning", "failure")
  ))
  c(
    "<!-- package-monitor-status:start -->",
    sprintf("**Current status: %s %s**", monitor_status_icon(overall), monitor_status_label(overall)),
    "",
    sprintf(
      "Last run: `%s` — %d OK, %d warnings, %d failures.",
      generated_at, counts[["ok"]], counts[["warning"]], counts[["failure"]]
    ),
    "",
    "[View the full GitHub-rendered report](reports/latest.md).",
    "<!-- package-monitor-status:end -->"
  )
}

monitor_replace_readme_status <- function(readme, status_lines) {
  lines <- readLines(readme, warn = FALSE)
  start <- match("<!-- package-monitor-status:start -->", lines)
  end <- match("<!-- package-monitor-status:end -->", lines)
  if (is.na(start) || is.na(end) || end < start) {
    lines <- c(lines, "", "## Latest health status", "", status_lines)
  } else {
    before <- if (start > 1L) lines[seq_len(start - 1L)] else character()
    after <- if (end < length(lines)) lines[seq.int(end + 1L, length(lines))] else character()
    lines <- c(before, status_lines, after)
  }
  writeLines(lines, readme, useBytes = TRUE)
}

monitor_render_reports <- function(results_dir, reports_dir = "reports",
                                   readme = "README.md") {
  results <- monitor_read_results(results_dir)
  lines <- monitor_report_lines(results)
  report_date <- substr(monitor_report_time(results), 1L, 10L)
  history_dir <- file.path(reports_dir, "history")
  dir.create(history_dir, recursive = TRUE, showWarnings = FALSE)
  latest <- file.path(reports_dir, "latest.md")
  history <- file.path(history_dir, paste0(report_date, ".md"))
  writeLines(lines, latest, useBytes = TRUE)
  writeLines(lines, history, useBytes = TRUE)
  monitor_replace_readme_status(readme, monitor_readme_status_lines(results))
  list(latest = latest, history = history, overall = monitor_overall_status(results))
}
