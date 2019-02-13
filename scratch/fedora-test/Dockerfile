FROM rhub/fedora-gcc:latest

RUN yum install -y v8-devel

RUN dnf install -y \
  gdal-devel \
  proj-devel \
  proj-epsg \
  proj-nad \
  geos-devel \
  udunits2-devel \
  R

RUN dnf install -y \
  protobuf-devel \
  protobuf-compiler \
  jq-devel \
  libcurl-devel \
  openssl-devel \
  nodejs

RUN npm install -g mapshaper
# RUN dnf install --nogpgcheck rstudio-latest-x86_64.rpm

RUN echo "options(repos = c(CRAN = \"https://cran.rstudio.com/\"))" >> /usr/lib64/R/etc/Rprofile.site

RUN R -e "install.packages(\"udunits2\",configure.args=\"--with-udunits2-include=/usr/include/udunits2/\")"
RUN R -e "install.packages(c(\"rmapshaper\", \"randgeo\"))"

RUN curl -LO https://github.com/ateucher/rmapshaper/files/1911058/statsnzregional-council-2018-clipped-generalised-GPKG.zip && \
  unzip statsnzregional-council-2018-clipped-generalised-GPKG.zip *.gpkg

COPY test.R /test.R

# RUN curl -LO https://download2.rstudio.org/rstudio-server-rhel-1.1.447-x86_64.rpm && \
# dnf install -y rstudio-server-rhel-1.1.447-x86_64.rpm
