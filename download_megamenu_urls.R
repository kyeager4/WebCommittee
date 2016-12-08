library(dplyr)
library(stringi)
library(xml2)
library(rvest)

#' Read the library homepage
x <- xml2::read_html("http://library.kent.edu") 

#' Extract the URLs linked in the megamenu
links <- x %>%
  rvest::html_nodes("ul.megamenu-wrapper li a") %>%
  rvest::html_attr("href")

#' Append relative URLs with "http://www.library.kent.edu"
links2 <- xml2::url_absolute(links, "http://www.library.kent.edu")

#' Drop URLs not containing string "library" or "libguides" (and keep only unique)
links3 <- unique(links2[which(stringi::stri_detect_regex(links2, "library|libguides"))])

#' (Optional) Check which URLs dropped
links2[which(!links2 %in% links3)]

#' (Optional) Write URLs to text file that is usable by wget
#'   - To write all links: change first argument to links2
#'   - To write just library.kent.edu and libguides links (no omeka or external links): change first argument to links3
writeLines(links2, "megamenu_links.txt")









