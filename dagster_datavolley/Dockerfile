FROM python:3.12-slim

# Set the working directory to /app
WORKDIR /app

# Clone the project repository
COPY --chown=app:app . .

EXPOSE 3000

WORKDIR /app/datavolley_dagster

# Install the dependencies
RUN pip install -e ".[dev]"


CMD ["dagster", "dev", "--host", "0.0.0.0","--port","3000"]
