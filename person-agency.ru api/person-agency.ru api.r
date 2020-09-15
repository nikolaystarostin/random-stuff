#author: Nikolay Starostin

#COMMENTED CODE IS FOR MOSCOW

library(RCurl)
library(XML) # parse
require(httr)
library(readr) 
library(tidyverse) 
library(glue) # easy create links ''
library(writexl) # save in xlsx 

links <- c()

# Get all links on all companies at person-agency.ru/
#for (i in 1:40){
for (i in 1:12){
  #URL <- glue('https://person-agency.ru/cities/moskva.html?page={i}')
  URL <- glue('https://person-agency.ru/cities/sankt-peterburg.html?page={i}')
  parsed.html <- XML::htmlParse(content(GET(URL)))
  links <- append(links, xpathSApply(parsed.html, "//*[@class='title']", xmlGetAttr, 'href'))
}

# Delete errors
links <- links[-1] # 1 страница - реклама
#links <- links[c(-208, -588)] # страница компаний 208 и 588 давала ошибку 404


companies <- data.frame(name=character(), 
                        email=character(), 
                        link=character(), 
                        URL=character())

# Parse all companies pages for needed data

for (i in links){
  URL <- glue('https://person-agency.ru{i}')
  parsed.html <- XML::htmlParse(content(GET(URL)), encoding="UTF-8")
  name <- xpathSApply(parsed.html, "//h1[@class='text-left']", xmlValue)
  info <- xpathSApply(parsed.html, "//dl[@class='dl-horizontal']", xmlValue) %>% 
    str_replace_all('\n', '') 
  link <- info %>% 
    str_extract('Сайт:[[:punct:][:digit:]a-zA-Z]*') %>% 
    str_replace('Сайт:','')
  email <- info %>% 
    str_extract('E-mail:[[:punct:][:digit:]a-zA-Z]*') %>% 
    str_replace('E-mail:','')
  companies <- rbind(companies, data.frame(name, email, link, URL))
}

#write_xlsx(companies, 'K:/moscow.xlsx')
write_xlsx(companies, 'K:/spb.xlsx')
