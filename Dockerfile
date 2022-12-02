FROM r-base:4.1.2

RUN apt-get update \
    && apt install -y python3 default-jre default-jdk \
                libprotobuf-dev protobuf-compiler \
                libv8-dev libjq-dev libudunits2-0 \
                libudunits2-dev libgdal-dev \
    && R CMD javareconf
RUN rm -rf /var/lib/apt/lists/*

RUN R -e 'install.packages( \
            c("argparse", "sp", "sf", "raster", "dplyr", "spDataLarge", \
              "spData", "ggmap", "geojsonio", "xlsx", \
              "rJava", "xlsxjars", "geosphere"), \
            repos = c("https://cloud.r-project.org", \
                      "https://nowosad.github.io/drat/"))'

COPY src/* /app/

ENTRYPOINT [ "Rscript", "/app/main.R" ]
