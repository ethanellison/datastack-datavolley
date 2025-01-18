FROM python:3.12-slim

# Set the working directory to /app
WORKDIR /app

COPY --chown=app:app ./datavolley_dagster/setup.py ./datavolley_dagster/pyproject.toml ./

RUN pip install -e ".[dev]"

# Clone the project repository
COPY --chown=app:app . .
# Install the dependencies
EXPOSE 3000

WORKDIR /app/datavolley_dagster

CMD ["dagster", "dev", "--host", "0.0.0.0","--port","3000"]

