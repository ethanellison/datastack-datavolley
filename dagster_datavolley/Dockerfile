FROM python:3.12-slim

# Set the working directory to /app
WORKDIR /app

COPY requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Clone the project repository
COPY --chown=app:app . .

EXPOSE 3000

WORKDIR /app/datavolley_dagster

CMD ["dagster", "dev", "--host", "0.0.0.0","--port","3000"]
