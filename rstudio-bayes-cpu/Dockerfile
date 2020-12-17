FROM rocker/verse:4.0.0-ubuntu18.04

# Pulls rocker rstudio R version 4.0 on ubuntu

MAINTAINER "Ryan Bartelme rbartelme@arizona.edu"
# This image uses the Rocker verse RStudio image - thanks R OpenSci!

## Install CyVerse VICE Depends
## lsb is deprecated
RUN apt-get update && apt-get install -y lsb-base lsb-release wget \
  apt-transport-https python2.7 python-requests curl supervisor nginx gnupg2 \
  clang libfuse2

RUN curl "http://ftp.se.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb" -O && \
    dpkg -i libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb && \
    rm libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb

# Install iCommands
RUN wget https://files.renci.org/pub/irods/releases/4.1.10/ubuntu14/irods-icommands-4.1.10-ubuntu14-x86_64.deb && dpkg -i irods-icommands-4.1.10-ubuntu14-x86_64.deb

ADD https://github.com/hairyhenderson/gomplate/releases/download/v2.5.0/gomplate_linux-amd64 /usr/bin/gomplate
RUN chmod a+x /usr/bin/gomplate

# provide read and write access to Rstudio users for default R library location
RUN chmod -R 777 /usr/local/lib/R/site-library

COPY install_stan.R install_stan.R
RUN ["r", "install_stan.R"]

USER rstudio
RUN mkdir -p "${HOME}/.R"
RUN echo "CXX14FLAGS=-O3 -march=native -mtune=native -fPIC" >> "${HOME}/.R/Makevars" ; \
   echo "CXX14=clang++" >> "${HOME}/.R/Makevars"
USER root


# Installing the rest for stan
RUN R -e 'install.packages(c("bnlearn","ggfortify", "bayesplot", "brms", \
"coda", "loo", "projpred", "rstanarm", "rstantools", "shinystan", "tidybayes"), \
repos = "https://cloud.r-project.org")'

#install Rgraphviz from bioc
RUN R -e 'BiocManager::install("Rgraphviz")'

ENV PASSWORD "rstudio1"
RUN bash /etc/cont-init.d/userconf

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

COPY nginx.conf.tmpl /nginx.conf.tmpl
COPY rserver.conf /etc/rstudio/rserver.conf
COPY supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY supervisor-rstudio.conf /etc/supervisor/conf.d/rstudio.conf

# iCommands json configuration for rstudio user profile
USER rstudio
RUN mkdir /home/rstudio/.irods/
RUN echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "", "irods_zone_name": "iplant"}' >> /home/rstudio/.irods/irods_environment.json
RUN echo 'export PS1="[\u@cyverse] \w # "' >> /home/rstudio/.bash_profile
USER root


ENV REDIRECT_URL "http://localhost/"

ENTRYPOINT ["/usr/local/bin/run.sh"]
