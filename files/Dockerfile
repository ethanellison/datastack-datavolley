# Stage 1: Build stage (to install Filebrowser)
FROM ubuntu:20.04 AS builder

# Install necessary build dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install Filebrowser
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Stage 2: Runtime stage
FROM ubuntu:20.04

# Install only the necessary runtime dependencies
RUN apt-get update && \
    apt-get install -y \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy Filebrowser from the build stage
COPY --from=builder /usr/local/bin/filebrowser /usr/local/bin/filebrowser

# Create a directory for files (this is where Filebrowser will look for files)
RUN mkdir -p /files/datavolley

RUN mkdir -p /files/out

# Create a non-root user to run Filebrowser
RUN useradd -m filebrowser

RUN chown -R filebrowser:filebrowser /files
# Set the working directory to the files directory
WORKDIR /files

# Expose the port that Filebrowser will run on
EXPOSE 8080

# Run Filebrowser as the non-root user
USER filebrowser

# Command to run Filebrowser with the given directory


CMD ["filebrowser", "-r", "/files", "-a", "0.0.0.0", "--noauth"]
