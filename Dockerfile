FROM ghcr.io/dockerfast/python-opencv-headless:latest

RUN apt-get update \
    # Install requirements
    && python3 -m pip install --no-cache-dir \
        dlib python-dotenv watchdog schedule people-finder \
    # Remove tmp files
    && rm -rf /tmp/* /var/tmp/*

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
