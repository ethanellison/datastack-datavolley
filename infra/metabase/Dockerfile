FROM eclipse-temurin:21-jre


# Install curl and jq
RUN apt-get update && apt-get install -y curl jq

# Create necessary directories
RUN mkdir -p /app /plugins

# Download Metabase jar
RUN curl -L -o /app/metabase.jar https://downloads.metabase.com/latest/metabase.jar

# Download Dremio driver with latest version
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/DTECHrciszynski/metabase-dremio-driver/releases/latest | jq -r .tag_name) && \
    wget -O /plugins/dremio.metabase-driver.jar https://github.com/DTECHrciszynski/metabase-dremio-driver/releases/download/${LATEST_VERSION}/dremio.metabase-driver.jar

# Set environment variables
ENV MB_PLUGINS_DIR=/plugins

# Expose default port
EXPOSE 3000

# Default command
CMD ["java","--add-opens", "java.base/java.nio=ALL-UNNAMED", "-jar", "/app/metabase.jar"]