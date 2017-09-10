#install.packages("spacyr")
library(spacyr)
spacy_initialize(python_executable="/home/cdsw/r_env/bin/python")

txt <- c(d1 = "spaCy excels at large-scale information extraction tasks.",
         d2 = "Mr. Smith goes to North Carolina.")

# process documents and obtain a data.table
parsedtxt <- spacy_parse(txt, lemma = FALSE)
entity_extract(parsedtxt)
