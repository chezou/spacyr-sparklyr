#!/bin/bash

conda create -p ~/r_env --copy -y -q -c r r-essentials python=2.7
conda install -p ~/r_env -y -q -c conda-forge spacy
source activate ~/r_env

# Download dataset for English
python -m spacy download en

# Check loading spacy on Python
python -c "import spacy; spacy.load('en'); print('OK')"

# Install spacyr
Rscript -e 'if(!require("spacyr", character.only = TRUE, quietly = TRUE)) install.packages("spacyr", dependencies = TRUE, repos="https://cran.r-project.org")'
source deactivate
cp -r R/* ~/r_env/lib/R/library/

# Change R script
sed -i "s,/home/cdsw,./r_env.zip,g" r_env/bin/R 
zip -r r_env.zip r_env
