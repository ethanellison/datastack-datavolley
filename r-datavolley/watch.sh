#!/bin/bash

# Directory to watch
WATCHED_DIR="/app/dvw"

Rscript main.R

# Command to execute when an event occurs (for demonstration, we'll just print a message)
on_change() {
    echo "Change detected in $WATCHED_DIR!"
    Rscript main.R
    # You can replace this with any command, for example:
    # curl -X POST http://your-api-endpoint.com
}

# Monitor the directory for any changes
inotifywait -m -e create,delete "$WATCHED_DIR" | while read path action file; do
    on_change
done
