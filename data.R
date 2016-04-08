start_date <- Sys.Date()-29 # as.Date("2016-01-17")
end_date <- Sys.Date()-1
traffic <- do.call(rbind, lapply(seq(start_date, end_date, "day"), function(date) {
  cat("Fetching Wikimedia & Wikipedia pageviews from ", as.character(date), "\n")
  # Write query and run it
  query <- paste0("USE wmf;
                   SELECT portal, COUNT(*) AS pageviews FROM (
                     SELECT
                       CASE WHEN uri_host IN('www.wikipedia.org','wikipedia.org')
                            THEN 'wikipedia' ELSE 'wikimedia' END AS portal
                     FROM webrequest ", wmf::date_clause(date)$date_clause, "
                       AND webrequest_source = 'text'
                       AND content_type RLIKE('^text/html')
                       AND uri_host IN('www.wikipedia.org','wikipedia.org', 'www.wikimedia.org', 'wikimedia.org', 'm.wikimedia.org')
                   ) AS pageviews GROUP BY portal;")
  results <- wmf::query_hive(query)
  results <- results[results$pageviews != "", ]
  return(cbind(date = date, referer = results, stringsAsFactors = FALSE))
}))
names(traffic) <- c('date', 'portal', 'pageviews')
readr::write_tsv(traffic, "~/portals-traffic.tsv")

dir.create("data")
system("scp stat2:/home/bearloga/portals-traffic.tsv data/")
