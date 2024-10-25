# Use the rocker/tidyverse base image
FROM rocker/tidyverse:latest

# Set environment variable to prevent warnings being treated as errors
ENV R_WARN_ON_STDERR=false

# Install system dependencies for pdftools and other packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpoppler-cpp-dev

# Install R packages
RUN Rscript -e 'install.packages("aws.s3", repos = "https://cloud.r-project.org")' \
    && Rscript -e 'install.packages("pdftools", repos = "https://cloud.r-project.org")' \
    && Rscript -e 'install.packages(c("volleyreport", "datavolley"), repos = c("https://openvolley.r-universe.dev", "https://cloud.r-project.org"))'

# Set the default working directory
WORKDIR /app

# Create /app directory inside the container
RUN mkdir -p /app/dvw

# Copy the contents of the local folder to /app inside the container
# (Make sure the local folder is in the same directory as your Dockerfile)
COPY ./main.R /app/main.R
# Set the default command
CMD ["Rscript", "/app/main.R"]
