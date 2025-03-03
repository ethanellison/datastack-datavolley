
# Stage 2: Final Image (Runtime)
FROM quay.io/jupyter/datascience-notebook:latest

# Set environment variable to suppress warnings during package installation
ENV R_WARN_ON_STDERR=false

# Install R packages in a single RUN step to optimize cache
RUN Rscript -e 'install.packages(c("datavolley", "ovlytics"), repos = c("https://openvolley.r-universe.dev", "https://cloud.r-project.org"))'

RUN Rscript -e 'install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))'

RUN Rscript -e 'install.packages("arrow", repos = c("https://apache.r-universe.dev", "https://cloud.r-project.org"))'
# Copy only the necessary libraries and packages from the build stage
# COPY --from=build-stage /usr/local/lib/R/site-library /usr/local/lib/R/site-library

WORKDIR /home
# Create the necessary directory and copy only necessary files
# COPY ./main.R /app/main.R
# COPY ./watch.sh /app/watch.sh
EXPOSE 8888

# Set the default command to run when the container starts
# CMD ["Rscript", "/app/main.R"]
