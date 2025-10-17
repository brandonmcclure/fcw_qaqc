# FROM r-base:4.2.2
FROM rocker/tidyverse:4.2.2

RUN apt-get update && apt-get -y install libglpk-dev

RUN R -e "install.packages('devtools', dependencies=TRUE)"

WORKDIR /src

COPY . /src
RUN R -e "install.packages(c('zoo', 'padr', 'plotly', 'feather', 'RcppRoll', 'yaml','ggpubr', 'profvis', 'Rcpp', 'magrittr','arrow','janitor','tidyverse','rvest','readxl'))"

RUN R -e "install.packages('miniCRAN')"

RUN R -e "library(devtools); devtools::build(path='/tmp', binary = FALSE)"
CMD ["R", "-e",  "library(miniCRAN); mypackages <- rownames(installed.packages()); makeRepo(mypackages, path = '/mnt/repo', type = 'source', Rversion = '4.2.2'); tags <- 'fcw.qaqc';jpeg(file='depgraph.jpeg');dg <- makeDepGraph(tags, enhances = TRUE, availPkgs = cranJuly2014);set.seed(1);plot(dg, legendPosition = c(-1, 1), vertex.size = 20);dev.off();" ]