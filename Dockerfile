FROM rocker/r-ver:4.1.0

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV S6_VERSION=v2.1.0.2
ENV SHINY_SERVER_VERSION=latest
ENV PANDOC_VERSION=default

RUN /rocker_scripts/install_shiny_server.sh
RUN /rocker_scripts/install_tidyverse.sh
RUN /rocker_scripts/install_geospatial.sh


# Install R packages that are required
RUN R  -e "install.packages('here')"
RUN R  -e "install.packages('colorRamps')"
RUN R  -e "install.packages('colorspace')"
RUN R  -e "install.packages('rerddap')"
RUN R  -e "install.packages('htmlwidgets')"
RUN R  -e "install.packages('sf')"


#COPY . /srv/shiny-server/
COPY global.R /srv/shiny-server/
COPY app.R /srv/shiny-server/
COPY icons8-buoy-50.png /srv/shiny-server/
COPY SST.Rproj /srv/shiny-server/
COPY ds582 /srv/shiny-server/ds582
COPY s_11au16 /srv/shiny-server/s_11au16
COPY data /srv/shiny-server/data
COPY so_cal_bath.csv srv/shiny-server/


EXPOSE 3838

CMD ["/init"]