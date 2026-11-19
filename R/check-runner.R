`%||%` <- function(x, y) {
  if (is.null(x) || !length(x)) y else x
}

monitor_now <- function() {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

monitor_issue <- function(severity, code, path = "root", message) {
  severity <- match.arg(severity, c("warning", "failure"))
  data.frame(
    severity = severity,
    code = as.character(code),
    path = as.character(path),
    message = as.character(message),
    stringsAsFactors = FALSE
  )
}

monitor_bind_issues <- function(...) {
  issues <- Filter(function(x) !is.null(x) && nrow(x), list(...))
  if (!length(issues)) {
    return(data.frame(
      severity = character(), code = character(), path = character(),
      message = character(), stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, issues)
}

monitor_class <- function(x) {
  paste(class(x), collapse = "/")
}

monitor_structure <- function(x, path = "root") {
  row <- function(path, kind, class, width = NA_integer_) {
    data.frame(
      path = path,
      kind = kind,
      class = class,
      width = as.integer(width),
      stringsAsFactors = FALSE
    )
  }

  if (is.data.frame(x)) {
    out <- list(row(path, "data.frame", monitor_class(x)))
    if (length(x)) {
      for (name in names(x)) {
        out[[length(out) + 1L]] <- monitor_structure(
          x[[name]], paste0(path, ".", name)
        )
      }
    }
    return(do.call(rbind, out))
  }

  if (is.matrix(x)) {
    return(row(path, "matrix", monitor_class(x), ncol(x)))
  }

  if (is.list(x)) {
    out <- list(row(path, "list", monitor_class(x)))
    if (length(x)) {
      labels <- names(x)
      if (is.null(labels)) labels <- rep("", length(x))
      for (i in seq_along(x)) {
        child <- if (nzchar(labels[[i]])) {
          paste0(path, ".", labels[[i]])
        } else {
          paste0(path, "[[", i, "]]")
        }
        out[[length(out) + 1L]] <- monitor_structure(x[[i]], child)
      }
    }
    return(do.call(rbind, out))
  }

  row(path, "vector", monitor_class(x))
}

monitor_extract <- function(x, path = "root") {
  if (is.null(path) || !length(path) || identical(path, "root") || identical(path, "")) {
    return(x)
  }
  parts <- if (length(path) > 1L) path else strsplit(path, ".", fixed = TRUE)[[1L]]
  current <- x
  for (part in parts) {
    if (!is.list(current) || is.null(current[[part]])) return(NULL)
    current <- current[[part]]
  }
  current
}

monitor_all_missing <- function(x) {
  if (!length(x)) return(TRUE)
  missing <- is.na(x)
  if (is.character(x)) missing <- missing | !nzchar(trimws(x))
  all(missing)
}

monitor_validate_expectation <- function(output, expectation) {
  path <- expectation$path %||% "root"
  value <- monitor_extract(output, path)
  issues <- list()
  add <- function(severity, code, message) {
    issues[[length(issues) + 1L]] <<- monitor_issue(severity, code, path, message)
  }

  if (is.null(value)) {
    add("failure", "missing_output_path", sprintf("Expected output path '%s' is missing.", path))
    return(do.call(monitor_bind_issues, issues))
  }

  expected_kind <- expectation$kind %||% NULL
  actual_kind <- if (is.data.frame(value)) "data.frame" else if (is.matrix(value)) {
    "matrix"
  } else if (is.list(value)) "list" else "vector"
  if (!is.null(expected_kind) && !identical(actual_kind, expected_kind)) {
    add("failure", "unexpected_kind", sprintf(
      "Expected %s but received %s.", expected_kind, actual_kind
    ))
  }

  rows <- if (is.data.frame(value) || is.matrix(value)) nrow(value) else length(value)
  if (!is.null(expectation$min_rows) && rows < expectation$min_rows) {
    add(expectation$min_rows_severity %||% "warning", "too_few_rows", sprintf(
      "Expected at least %d rows/items but received %d.", expectation$min_rows, rows
    ))
  }

  if (!is.null(expectation$required_columns)) {
    if (!is.data.frame(value)) {
      add("failure", "columns_unavailable", "Required columns were specified for a non-tabular value.")
    } else {
      missing <- setdiff(expectation$required_columns, names(value))
      if (length(missing)) {
        add("failure", "missing_required_columns", paste(
          "Missing required columns:", paste(missing, collapse = ", ")
        ))
      }
    }
  }

  if (!is.null(expectation$nonempty_columns) && is.data.frame(value)) {
    for (column in intersect(expectation$nonempty_columns, names(value))) {
      if (monitor_all_missing(value[[column]])) {
        add("warning", "all_missing_column", sprintf("Column '%s' is entirely missing or empty.", column))
      }
    }
  }

  if (isTRUE(expectation$finite)) {
    if (!is.numeric(value)) {
      add("failure", "non_numeric_output", "Expected numeric output for the finite-values check.")
    } else if (any(!is.finite(value))) {
      add("failure", "non_finite_values", "Output contains NA, NaN, or infinite numeric values.")
    }
  }

  if (!is.null(expectation$ncol)) {
    actual_ncol <- if (is.matrix(value) || is.data.frame(value)) ncol(value) else NA_integer_
    if (is.na(actual_ncol) || actual_ncol != expectation$ncol) {
      add("failure", "unexpected_width", sprintf(
        "Expected %d columns but received %s.", expectation$ncol,
        if (is.na(actual_ncol)) "a non-tabular value" else actual_ncol
      ))
    }
  }

  do.call(monitor_bind_issues, issues)
}

monitor_validate_output <- function(output, expectations = list(), validator = NULL) {
  issues <- lapply(expectations, function(x) monitor_validate_expectation(output, x))
  issues <- do.call(monitor_bind_issues, issues)

  if (!is.null(validator)) {
    custom <- validator(output)
    if (!is.null(custom)) {
      if (!is.data.frame(custom) || !all(c("severity", "code", "path", "message") %in% names(custom))) {
        stop("Custom validators must return monitor_issue() rows or NULL.", call. = FALSE)
      }
      issues <- monitor_bind_issues(issues, custom)
    }
  }
  issues
}

monitor_baseline_path <- function(check_id, baseline_dir = "baselines") {
  file.path(baseline_dir, paste0(check_id, ".json"))
}

monitor_read_baseline <- function(check_id, baseline_dir = "baselines") {
  path <- monitor_baseline_path(check_id, baseline_dir)
  if (!file.exists(path)) return(NULL)
  jsonlite::read_json(path, simplifyVector = TRUE)
}

monitor_compare_structure <- function(current, baseline) {
  if (is.null(baseline) || is.null(baseline$schema)) {
    return(monitor_issue(
      "warning", "baseline_missing", "root",
      "No structural baseline exists for this check."
    ))
  }

  expected <- as.data.frame(baseline$schema, stringsAsFactors = FALSE)
  current <- as.data.frame(current, stringsAsFactors = FALSE)
  issues <- list()
  add <- function(severity, code, path, message) {
    issues[[length(issues) + 1L]] <<- monitor_issue(severity, code, path, message)
  }

  missing <- setdiff(expected$path, current$path)
  for (path in missing) {
    add("failure", "structure_removed", path, "Baseline field or component is missing.")
  }

  added <- setdiff(current$path, expected$path)
  for (path in added) {
    add("warning", "structure_added", path, "New field or component is not present in the baseline.")
  }

  common <- intersect(expected$path, current$path)
  for (path in common) {
    old <- expected[match(path, expected$path), , drop = FALSE]
    new <- current[match(path, current$path), , drop = FALSE]
    if (!identical(as.character(old$kind), as.character(new$kind)) ||
        !identical(as.character(old$class), as.character(new$class))) {
      add("failure", "type_changed", path, sprintf(
        "Structure changed from %s (%s) to %s (%s).",
        old$kind, old$class, new$kind, new$class
      ))
    }
    old_width <- suppressWarnings(as.integer(old$width))
    new_width <- suppressWarnings(as.integer(new$width))
    if (identical(as.character(old$kind), "matrix") &&
        !is.na(old_width) && !is.na(new_width) && old_width != new_width) {
      add("failure", "matrix_width_changed", path, sprintf(
        "Matrix width changed from %d to %d.", old_width, new_width
      ))
    }
  }

  do.call(monitor_bind_issues, issues)
}

monitor_sample <- function(x, rows = 3L, columns = 8L) {
  if (is.data.frame(x)) {
    # Convert data.table subclasses before column selection: `DT[, 1:8]`
    # evaluates the expression and returns integers instead of selecting fields.
    out <- as.data.frame(utils::head(x, rows), stringsAsFactors = FALSE)
    out <- out[, seq_len(min(ncol(out), columns)), drop = FALSE]
    return(lapply(out, function(column) {
      if (is.list(column)) vapply(column, function(item) {
        paste(utils::capture.output(str(item, max.level = 1L)), collapse = " ")
      }, character(1L)) else column
    }))
  }
  if (is.matrix(x)) {
    return(unname(x[seq_len(min(nrow(x), rows)), seq_len(min(ncol(x), columns)), drop = FALSE]))
  }
  if (is.list(x)) {
    keep <- seq_len(min(length(x), rows))
    out <- lapply(x[keep], monitor_sample, rows = rows, columns = columns)
    names(out) <- names(x)[keep]
    return(out)
  }
  utils::head(x, rows)
}

monitor_status <- function(issues, error = NULL, warnings = character()) {
  if (!is.null(error) || any(issues$severity == "failure")) return("failure")
  if (length(warnings) || any(issues$severity == "warning")) return("warning")
  "ok"
}

monitor_run_check <- function(id, package, code, expectations = list(),
                              validator = NULL, baseline_dir = "baselines",
                              sample_rows = 3L) {
  stopifnot(is.character(id), length(id) == 1L, nzchar(id), is.function(code))
  started_at <- monitor_now()
  started <- proc.time()[["elapsed"]]
  captured_warnings <- character()
  error_message <- NULL

  output <- tryCatch(
    withCallingHandlers(
      code(),
      warning = function(warning) {
        captured_warnings <<- c(captured_warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) {
      error_message <<- conditionMessage(error)
      NULL
    }
  )

  elapsed <- unname(proc.time()[["elapsed"]] - started)
  schema <- if (is.null(error_message)) monitor_structure(output) else NULL
  validation_issues <- if (is.null(error_message)) {
    tryCatch(
      monitor_validate_output(output, expectations, validator),
      error = function(error) monitor_issue(
        "failure", "validator_error", "root", conditionMessage(error)
      )
    )
  } else monitor_bind_issues()

  baseline_issues <- monitor_bind_issues()
  if (is.null(error_message) && !is.null(baseline_dir)) {
    baseline_issues <- monitor_compare_structure(
      schema, monitor_read_baseline(id, baseline_dir)
    )
  }

  max_elapsed <- vapply(expectations, function(x) x$max_elapsed_seconds %||% Inf, numeric(1L))
  timing_issue <- monitor_bind_issues()
  if (length(max_elapsed) && is.finite(min(max_elapsed)) && elapsed > min(max_elapsed)) {
    timing_issue <- monitor_issue(
      "warning", "slow_response", "root",
      sprintf("Check took %.3f seconds; warning threshold is %.3f seconds.", elapsed, min(max_elapsed))
    )
  }

  issues <- monitor_bind_issues(validation_issues, baseline_issues, timing_issue)
  list(
    schema_version = 1L,
    id = id,
    package = package,
    status = monitor_status(issues, error_message, captured_warnings),
    started_at = started_at,
    finished_at = monitor_now(),
    elapsed_seconds = round(elapsed, 3L),
    warnings = unique(captured_warnings),
    error = error_message,
    issues = issues,
    schema = schema,
    sample = if (is.null(error_message)) monitor_sample(output, sample_rows) else NULL
  )
}

monitor_write_result <- function(result, results_dir = "results") {
  dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(results_dir, paste0(result$id, ".json"))
  jsonlite::write_json(
    result, path, pretty = TRUE, auto_unbox = TRUE, na = "null", null = "null"
  )
  path
}

monitor_write_baseline <- function(result, baseline_dir = "baselines") {
  if (is.null(result$schema) || identical(result$status, "failure")) {
    stop("Refusing to baseline a failed check or a result without a schema.", call. = FALSE)
  }
  dir.create(baseline_dir, recursive = TRUE, showWarnings = FALSE)
  path <- monitor_baseline_path(result$id, baseline_dir)
  baseline <- list(
    schema_version = 1L,
    check_id = result$id,
    created_at = monitor_now(),
    schema = result$schema
  )
  jsonlite::write_json(
    baseline, path, pretty = TRUE, auto_unbox = TRUE, na = "null", null = "null"
  )
  path
}

monitor_summarize <- function(results) {
  if (!length(results)) {
    return(data.frame(id = character(), package = character(), status = character()))
  }
  do.call(rbind, lapply(results, function(result) data.frame(
    id = result$id,
    package = result$package,
    status = result$status,
    elapsed_seconds = result$elapsed_seconds,
    issue_count = nrow(result$issues),
    stringsAsFactors = FALSE
  )))
}
