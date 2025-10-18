# FROM r-base:4.2.2
FROM rocker/tidyverse:4.2.2

RUN apt-get update && apt-get -y install libglpk-dev

RUN R -e "install.packages('devtools', dependencies=TRUE)"

WORKDIR /src

COPY . /src
RUN R -e "install.packages(c('zoo', 'padr', 'plotly', 'feather', 'RcppRoll', 'yaml','ggpubr', 'profvis', 'Rcpp', 'magrittr','arrow','janitor','tidyverse','rvest','readxl'))"

RUN R -e "install.packages('miniCRAN')"

VOLUME "/mnt"
CMD ["R", "-e", "library(devtools); devtools::build(path='/mnt', binary = FALSE)"]

