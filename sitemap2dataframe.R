library(dplyr)
library(tidyr)
library(stringi)
library(lubridate)
library(xml2)
library(rvest)


#' Sitemap url for library.kent.edu
url <- "http://www.library.kent.edu/sitemap.xml"


#' Read in the sitemap and extract each link (== each row of the "table")
sitemap_raw <- read_html(url) %>%
  html_nodes("url")


#' For each url in the sitemap (i.e., each element in the list):
#'   - Turn into a data frame with two variables: 
#'      - "varname" (the names of all child elements)
#'      - "valname" (the actual text associated with each child element)
#'   - use tidyr::spread() to reshape to wide format (key=varname, value=valname)
#'   - use bind_rows to convert from list to a single dataframe

sitemap <- lapply(sitemap_raw, function(x){
  data.frame(varname = html_name(xml_contents(x)),
             valname = html_text(xml_contents(x)),
             stringsAsFactors=FALSE) %>%
    spread(varname, valname)}
  ) %>%
  bind_rows()


#' Finishing touches: reorder columns to match the actual sitemap, and convert
#' the lastmod variable to a date
sitemap <- sitemap %>% 
  select(loc, lastmod, changefreq, priority) %>%
  mutate(date = parse_date_time2(lastmod, orders=c("Y!m!*d!H!M!z!*"))) %>%
  arrange(loc)


#' (Optional) Write to file
write.csv(sitemap, paste0("sitemap2dataframe", today(), ".csv"), row.names=FALSE, na="")

