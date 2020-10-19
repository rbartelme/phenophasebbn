FROM rocker/verse:3.6.2

# Pulls rocker rstudio R version 3.6.2

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

# Installing the rest for stan
RUN install2.r -s --error \
bnlearn \
ggfortify \
bayesplot \
brms \
coda \
loo \
projpred \
rstanarm \
rstantools \
shinystan \
tidybayes

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
USER root


ENV REDIRECT_URL "http://localhost/"

ENTRYPOINT ["/usr/local/bin/run.sh"]
