FROM rhub/fedora-gcc:latest

RUN dnf install -y \
  v8-314-devel \
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
RUN R -e "install.packages(\"rmapshaper\")"

COPY test.R /test.R
