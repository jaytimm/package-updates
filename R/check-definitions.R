monitor_retry <- function(code, attempts = 2L, delay_seconds = 5,
                          retry_pattern = "loading|cold start|temporar|timeout|timed out|connection|download|429|502|503|504") {
  stopifnot(is.function(code), attempts >= 1L)
  last_error <- NULL
  for (attempt in seq_len(attempts)) {
    value <- tryCatch(code(), error = function(error) {
      last_error <<- error
      NULL
    })
    if (is.null(last_error)) return(value)
    retryable <- grepl(retry_pattern, conditionMessage(last_error), ignore.case = TRUE)
    if (!retryable || attempt == attempts) stop(last_error)
    Sys.sleep(delay_seconds)
    last_error <- NULL
  }
}

monitor_ncbi_key <- function() {
  key <- Sys.getenv("NCBI_API_KEY")
  if (nzchar(key)) key else NULL
}

monitor_huggingface_token <- function() {
  token <- Sys.getenv("HUGGINGFACE_API_TOKEN")
  if (!nzchar(token)) {
    stop("HUGGINGFACE_API_TOKEN is not configured.", call. = FALSE)
  }
  token
}

monitor_fixture_pmids <- function() c("38136652", "11250746")
monitor_fixture_oa_pmids <- function() c("11250746", "11573492")

monitor_embedding_validator <- function(output) {
  if (!is.matrix(output) || nrow(output) != 3L || ncol(output) < 1L) {
    return(monitor_issue(
      "failure", "embedding_shape", "root",
      "Expected three non-empty embedding rows."
    ))
  }
  norms <- sqrt(rowSums(output^2))
  if (any(!is.finite(norms)) || any(norms == 0)) {
    return(monitor_issue(
      "failure", "embedding_norm", "root",
      "Embedding rows must have finite, non-zero norms."
    ))
  }
  normalized <- output / norms
  similarities <- tcrossprod(normalized)
  similar_pair <- similarities[1L, 2L]
  unrelated_pairs <- c(similarities[1L, 3L], similarities[2L, 3L])
  if (similar_pair <= max(unrelated_pairs)) {
    return(monitor_issue(
      "failure", "embedding_similarity", "root",
      sprintf(
        "Similar-sentence score %.4f did not exceed unrelated scores (%.4f, %.4f).",
        similar_pair, unrelated_pairs[[1L]], unrelated_pairs[[2L]]
      )
    ))
  }
  NULL
}

monitor_puremoe_local_smoke <- function() {
  icites <- data.table::data.table(
    pmid = c("1", "2"),
    citation_net = list(
      data.table::data.table(from = c("1", "200"), to = c("100", "1")),
      data.table::data.table(from = c("2", "200"), to = c("100", "2"))
    )
  )
  annotations <- data.table::data.table(
    pmid = c("1", "2"), type = "MeSH",
    DescriptorUI = c("D1", "D1"), DescriptorName = c("Alpha", "Alpha")
  )
  frequencies <- data.table::data.table(
    DescriptorUI = "D1", DescriptorName = "Alpha",
    n_pmids = 1000, prop_total = 0.001
  )
  list(
    endpoints = puremoe::endpoint_info(),
    snowball = puremoe::citation_snowball(
      icites, direction = "both", min_links = 2L
    ),
    keyness = puremoe::mesh_keyness(annotations, frequencies)
  )
}

monitor_textpress_local_smoke <- function() {
  corpus <- data.frame(
    doc_id = 1L,
    text = "Dr. Smith's well-known work. They've re-tested it.",
    stringsAsFactors = FALSE
  )
  sentences <- textpress::nlp_split_sentences(corpus, by = "doc_id")
  tokens <- textpress::nlp_tokenize_text(
    sentences, by = c("doc_id", "sentence_id"), include_spans = TRUE,
    method = "biber"
  )
  cast <- textpress::nlp_cast_tokens(tokens)
  regex <- textpress::search_regex(sentences, "re-tested", by = "doc_id")
  dictionary <- textpress::search_dict(
    sentences, terms = c("work", "it"), by = "doc_id"
  )
  embeddings <- matrix(
    c(1, 0, 0, 1), nrow = 2L, byrow = TRUE,
    dimnames = list(c("a", "b"), NULL)
  )
  vector <- textpress::search_vector(embeddings, c(1, 0), n = 2L)
  list(
    sentences = sentences,
    tokens = cast,
    regex = regex,
    dictionary = dictionary,
    vector = vector
  )
}

monitor_textpress_local_validator <- function(output) {
  issues <- list()
  add <- function(code, path, message) {
    issues[[length(issues) + 1L]] <<- monitor_issue(
      "failure", code, path, message
    )
  }

  expected_sentences <- c(
    "Dr. Smith's well-known work.",
    "They've re-tested it."
  )
  actual_sentences <- trimws(output$sentences$text)
  if (!identical(actual_sentences, expected_sentences)) {
    add(
      "sentence_abbreviation_boundary", "sentences",
      "Sentence splitting must protect 'Dr.' while retaining the two real sentence boundaries."
    )
  }

  expected_tokens <- list(
    `1.1` = c("Dr", ".", "Smith", "'s", "well-known", "work", "."),
    `1.2` = c("They", "'ve", "re-tested", "it", ".")
  )
  actual_tokens <- split(output$tokens$token, output$tokens$id)
  if (!identical(actual_tokens[names(expected_tokens)], expected_tokens)) {
    add(
      "biber_token_contract", "tokens",
      "Biber tokens must separate punctuation and contraction suffixes while preserving intra-word hyphens."
    )
  }

  sentence_ids <- paste(
    output$sentences$doc_id, output$sentences$sentence_id, sep = "."
  )
  source <- output$sentences$text[match(output$tokens$id, sentence_ids)]
  recovered <- substring(source, output$tokens$start, output$tokens$end)
  recovered <- sub("^’", "'", recovered)
  if (anyNA(recovered) || !identical(recovered, output$tokens$token)) {
    add(
      "biber_source_spans", "tokens",
      "Every Biber token span must recover that token from the original sentence text."
    )
  }

  do.call(monitor_bind_issues, issues)
}

monitor_check_definitions <- function() {
  list(
    list(
      id = "puremoe_pubmed_search", package = "puremoe", kind = "live",
      code = function() puremoe::search_pubmed(
        '"doxorubicin"[Title/Abstract] AND "cardiotoxicity"[Title/Abstract]',
        retmax = 20L
      ),
      expectations = list(list(
        kind = "vector", min_rows = 10L, max_elapsed_seconds = 15
      ))
    ),
    list(
      id = "puremoe_pubmed_abstracts", package = "puremoe", kind = "live",
      code = function() puremoe::get_records(
        monitor_fixture_pmids(), "pubmed_abstracts", cores = 1L, sleep = 0.1,
        ncbi_key = monitor_ncbi_key()
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 2L,
        required_columns = c(
          "pmid", "doi", "year", "pubtype", "journal", "articletitle",
          "abstract", "annotations"
        ),
        nonempty_columns = c("pmid", "articletitle"),
        max_elapsed_seconds = 20
      ))
    ),
    list(
      id = "puremoe_pubmed_affiliations", package = "puremoe", kind = "live",
      code = function() puremoe::get_records(
        monitor_fixture_pmids(), "pubmed_affiliations", cores = 1L, sleep = 0.1,
        ncbi_key = monitor_ncbi_key()
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 2L,
        required_columns = c("pmid", "Author", "Affiliation"),
        nonempty_columns = c("pmid", "Author", "Affiliation"),
        max_elapsed_seconds = 20
      ))
    ),
    list(
      id = "puremoe_icite", package = "puremoe", kind = "live",
      code = function() puremoe::get_records(
        monitor_fixture_pmids(), "icites", cores = 1L, sleep = 0.1,
        icite_timeout = 30
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 2L,
        required_columns = c(
          "pmid", "citation_count", "relative_citation_ratio",
          "nih_percentile", "field_citation_rate", "is_research_article",
          "is_clinical", "provisional", "citation_net", "cited_by_clin"
        ),
        nonempty_columns = c("pmid", "citation_count"),
        max_elapsed_seconds = 35
      ))
    ),
    list(
      id = "puremoe_pubtator", package = "puremoe", kind = "live",
      code = function() puremoe::get_records(
        monitor_fixture_pmids(), "pubtator", cores = 1L, sleep = 0.1
      ),
      expectations = list(
        list(
          path = "entities", kind = "data.frame", min_rows = 1L,
          required_columns = c(
            "pmid", "mention_index", "id", "text", "type", "identifier",
            "tiab", "start", "end", "passage_text", "passage_offset"
          ),
          nonempty_columns = c("pmid", "text", "type"),
          max_elapsed_seconds = 20
        ),
        list(
          path = "relations", kind = "data.frame",
          required_columns = c(
            "pmid", "relation_id", "relation_type", "score",
            "ent1_mention_index", "ent1_type", "ent2_mention_index", "ent2_type"
          )
        )
      )
    ),
    list(
      id = "puremoe_pmc_id_converter", package = "puremoe", kind = "live",
      code = function() puremoe::pmid_to_pmc(
        monitor_fixture_oa_pmids(), sleep = 0.1
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 2L,
        required_columns = c("pmid", "pmcid", "doi"),
        nonempty_columns = c("pmid", "pmcid"),
        max_elapsed_seconds = 20
      ))
    ),
    list(
      id = "puremoe_pmc_oa_url", package = "puremoe", kind = "live",
      code = function() puremoe::pmid_to_ftp(
        monitor_fixture_oa_pmids(), sleep = 0.1,
        ncbi_key = monitor_ncbi_key()
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 1L,
        required_columns = c("pmid", "pmcid", "doi", "url"),
        nonempty_columns = c("pmid", "pmcid", "url"),
        max_elapsed_seconds = 30
      ))
    ),
    list(
      id = "puremoe_pmc_fulltext", package = "puremoe", kind = "live",
      code = function() {
        oa <- puremoe::pmid_to_ftp(
          monitor_fixture_oa_pmids(), sleep = 0.1,
          ncbi_key = monitor_ncbi_key()
        )
        if (is.null(oa) || !nrow(oa)) stop("No PMC open-access URL was resolved.")
        puremoe::get_records(
          oa$url[[1L]], "pmc_fulltext", cores = 1L, sleep = 0.1
        )
      },
      expectations = list(list(
        kind = "data.frame", min_rows = 1L,
        required_columns = c("pmid", "section", "text"),
        nonempty_columns = c("pmid", "text"),
        max_elapsed_seconds = 40
      ))
    ),
    list(
      id = "puremoe_mesh_thesaurus", package = "puremoe", kind = "live",
      code = function() monitor_retry(
        function() puremoe::data_mesh_thesaurus(force_install = TRUE),
        attempts = 2L, delay_seconds = 2
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 1000L, max_elapsed_seconds = 90
      ))
    ),
    list(
      id = "puremoe_mesh_trees", package = "puremoe", kind = "live",
      code = function() monitor_retry(
        function() puremoe::data_mesh_trees(force_install = TRUE),
        attempts = 2L, delay_seconds = 2
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 1000L, max_elapsed_seconds = 90
      ))
    ),
    list(
      id = "puremoe_local_smoke", package = "puremoe", kind = "local",
      code = monitor_puremoe_local_smoke,
      expectations = list(
        list(path = "endpoints", kind = "vector", min_rows = 5L),
        list(
          path = "snowball", kind = "data.frame", min_rows = 4L,
          required_columns = c(
            "pmid", "seed", "cited_links", "citing_links", "link_count"
          )
        ),
        list(
          path = "keyness", kind = "data.frame", min_rows = 1L,
          required_columns = c(
            "DescriptorUI", "DescriptorName", "corpus_count", "baseline_prop",
            "direction", "log_odds", "z"
          )
        )
      )
    ),
    list(
      id = "textpress_rss", package = "textpress", kind = "live",
      code = function() textpress::fetch_rss(
        "https://rss.politico.com/congress.xml", cores = 1L
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 5L,
        required_columns = c(
          "doc_id", "url", "title", "published_at", "source", "language",
          "country", "feed_url", "feed_title", "updated_at", "author",
          "description", "item_id"
        ),
        nonempty_columns = c("url", "title", "feed_url"),
        max_elapsed_seconds = 25
      ))
    ),
    list(
      id = "textpress_wikipedia_search", package = "textpress", kind = "live",
      code = function() textpress::fetch_wiki_urls("Doxorubicin", limit = 3L),
      expectations = list(list(
        kind = "vector", min_rows = 3L, max_elapsed_seconds = 15
      ))
    ),
    list(
      id = "textpress_wikipedia_references", package = "textpress", kind = "live",
      code = function() textpress::fetch_wiki_refs(
        "https://en.wikipedia.org/wiki/Doxorubicin", n = 10L
      ),
      expectations = list(list(
        kind = "data.frame", min_rows = 5L,
        required_columns = c("source_url", "ref_id", "ref_url"),
        nonempty_columns = c("source_url", "ref_id", "ref_url"),
        max_elapsed_seconds = 20
      ))
    ),
    list(
      id = "textpress_read_urls", package = "textpress", kind = "live",
      code = function() textpress::read_urls(
        "https://en.wikipedia.org/wiki/Doxorubicin",
        cores = 1L, exclude_wiki_refs = TRUE
      ),
      expectations = list(
        list(
          path = "text", kind = "data.frame", min_rows = 10L,
          required_columns = c("doc_id", "url", "node_id", "parent_heading", "text"),
          nonempty_columns = c("doc_id", "url", "node_id", "text"),
          max_elapsed_seconds = 25
        ),
        list(
          path = "meta", kind = "data.frame", min_rows = 1L,
          required_columns = c("doc_id", "url", "h1_title", "date", "source"),
          nonempty_columns = c("doc_id", "url", "h1_title", "source")
        )
      )
    ),
    list(
      id = "textpress_huggingface_embeddings", package = "textpress", kind = "live",
      code = function() monitor_retry(
        function() textpress::util_fetch_embeddings(
          c(
            similar_a = "The cat rests on the warm sofa.",
            similar_b = "A cat is sleeping on a couch.",
            unrelated = "Markets opened lower after the rate announcement."
          ),
          api_token = monitor_huggingface_token()
        ),
        attempts = 2L,
        delay_seconds = 10
      ),
      expectations = list(list(
        kind = "matrix", min_rows = 3L, finite = TRUE,
        max_elapsed_seconds = 45
      )),
      validator = monitor_embedding_validator
    ),
    list(
      id = "textpress_local_smoke", package = "textpress", kind = "local",
      code = monitor_textpress_local_smoke,
      expectations = list(
        list(path = "sentences", kind = "data.frame", min_rows = 2L),
        list(path = "tokens", kind = "data.frame", min_rows = 5L),
        list(path = "regex", kind = "data.frame", min_rows = 1L),
        list(path = "dictionary", kind = "data.frame", min_rows = 1L),
        list(path = "vector", kind = "data.frame", min_rows = 2L)
      ),
      validator = monitor_textpress_local_validator
    )
  )
}
