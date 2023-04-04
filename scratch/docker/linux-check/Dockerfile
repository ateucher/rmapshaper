FROM jakubnowosad/rspatial_proj7:latest

# RUN sudo apt-get update && apt-get install -y curl

# RUN curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash - \
#   && sudo apt-get install -y libnode-dev libnode64 nodejs \
#   && npm install -g mapshaper

RUN Rscript -e "install.packages(c('devtools', 'sf', 'V8', 'sp', 'geojsonsf', 'readr', 'geojsonlint', 'rgdal', 'geojsonio'))"
