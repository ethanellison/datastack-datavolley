# Use a more efficient base image for R, e.g., rocker/r-ver
FROM rocker/tidyverse:4 AS build-stage

# Set environment variable to suppress warnings during package installation
ENV R_WARN_ON_STDERR=false

# Install system dependencies and necessary libraries in a single RUN step
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    inotify-tools && \
    # Clean up package manager cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Install R packages in a single RUN step to optimize cache
RUN Rscript -e 'install.packages("aws.s3")' && \
    Rscript -e 'install.packages(c("datavolley", "ovlytics"), repos = c("https://openvolley.r-universe.dev", "https://cloud.r-project.org"))'

# Stage 2: Final Image (Runtime)
FROM rocker/tidyverse:4 AS final-stage

# Set environment variable to suppress warnings during package installation
ENV R_WARN_ON_STDERR=false

# Install only the minimal runtime system dependencies in the final image
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    inotify-tools && \
    rm -rf /var/lib/apt/lists/*

# Copy only the necessary libraries and packages from the build stage
COPY --from=build-stage /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Copy the required application files into the final image
WORKDIR /app
# Create the necessary directory and copy only necessary files
COPY ./main.R /app/main.R
# COPY ./watch.sh /app/watch.sh

# Set appropriate permissions for the watch script
# RUN chmod +x /app/watch.sh

# Set the default command to run when the container starts
CMD ["Rscript", "/app/main.R"]
