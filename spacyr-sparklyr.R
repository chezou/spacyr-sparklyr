## spacyr example with sparklyr
# This example will extract named entity from text and extract with spark_apply() of sparklyr.
# [spacyr](https://github.com/kbenoit/spacyr) is R binding of [SpaCy](https://spacy.io/), which is Python library for NLP.
# spacyr requires Python with Spacy.
### Installation
# 1. Run `install_spacy.sh` on CDSW terminal
# 2. Install following packages on R session:
#   devtools::install_github("rstudio/sparklyr")
#   install.packages(c("janeaustenr"))
# 3. Run all

library(dplyr)
library(sparklyr)
library(janeaustenr)

config <- spark_config()

config$sparklyr.driver.memory <- "8G"
config$sparklyr.executor.memory <- "8G"
config$spark.yarn.executor.memoryOverhead <- "4g"

#### Configuration for spark_apply()
config[["spark.r.command"]] <- "./r_env.zip/r_env/bin/Rscript"
config[["spark.yarn.dist.archives"]] <- "r_env.zip"
config$sparklyr.apply.env.R_HOME <- "./r_env.zip/r_env/lib/R"
config$sparklyr.apply.env.RHOME <- "./r_env.zip/r_env"
config$sparklyr.apply.env.R_SHARE_DIR <- "./r_env.zip/r_env/lib/R/share"
config$sparklyr.apply.env.R_INCLUDE_DIR <- "./r_env.zip/r_env/lib/R/include"
config$sparklyr.apply.env.LD_LIBRARY_PATH <- "/opt/cloudera/parcels/Anaconda/lib"
config$sparklyr.apply.env.PYTHONPATH <- "./r_env.zip/r_env/lib/python2.7/site-packages/"

#### Connect spark
sc <- spark_connect(master = "yarn-client", config = config)

#### Concatinate texts per document
austen     <- austen_books()
text_by_book <- austen_books() %>%
  group_by(book) %>%
  mutate(text_by_book = paste0(text, collapse = " ")) %>% 
  select(book, text_by_book) %>%
  distinct() %>%
  rename(text = text_by_book)
text_by_book$doc_id <- seq.int(nrow(text_by_book))

#### Create Spark Data Frame
austen_tbl <- copy_to(sc, text_by_book, overwrite = TRUE)

#### Extract named entities with `spark_apply()`
entities <- austen_tbl %>%
  select(text) %>%
  spark_apply(
    function(e) 
    {
      lapply(e, function(k) {
          spacyr::spacy_initialize(python_executable="/opt/cloudera/parcels/Anaconda/bin/python")
          parsedtxt <- spacyr::spacy_parse(as.character(k), lemma = FALSE)
          spacyr::entity_extract(parsedtxt)
        }
      )
    },
    names = c("doc_id", "sentence_id", "entity", "entity_type"),
    packages = FALSE)

#### Show results
entities %>% head(10) %>% collect()

grouped_entities <- entities %>% 
  group_by(entity_type) %>% 
  count() %>% 
  arrange(desc(n)) %>%
  collect()
  

grouped_entities

#### Plot the graph

library(ggplot2)

p <- entities %>%
  collect() %>% 
  ggplot(aes(x=factor(entity_type)))
p <- p + scale_y_log10()
p + geom_bar()

#### Show Top 10 persons for each document

persons <- entities %>% 
  filter(entity_type == "PERSON") %>%
  group_by(doc_id, entity) %>%
  select(doc_id, entity) %>%
  count() %>%
  arrange(doc_id, desc(n))

persons %>% 
  filter(doc_id == "text1") %>%
  head(10) %>%
  collect()

persons %>% 
  filter(doc_id == "text2") %>%
  head(10) %>%
  collect()
