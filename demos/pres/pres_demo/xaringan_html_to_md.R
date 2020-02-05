library(rvest)

rmd_file <- "XaringanExample"
src_file <- paste(rmd_file, "html", sep = ".")
dst_file <- paste(rmd_file, "md", sep = ".")

pg <- read_html(src_file)
md <- pg %>% html_nodes(xpath = '//textarea[@id="source"]') %>% html_text()
cat(md, file = dst_file, sep = "\n", append = FALSE)
