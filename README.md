# spacyr example with sparklyr
 This example will extract named entity from text and extract with spark_apply() of sparklyr.
[spacyr](https://github.com/kbenoit/spacyr) is R binding of [SpaCy](https://spacy.io/), which is Python library for NLP.
spacyr requires Python with Spacy.

## Installation
1. Run `install_spacy.sh` on CDSW terminal
2. Install following packages on R session:
   devtools::install_github("rstudio/sparklyr")
   install.packages(c("janeaustenr"))
3. Run all