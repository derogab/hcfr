FROM ghcr.io/dockerfast/python-opencv-headless:latest

RUN \
    # Upgrade build tools
    python3 -m pip install --no-cache-dir --upgrade setuptools wheel \
    # Install requirements
    && python3 -m pip install --no-cache-dir \
        dlib python-dotenv watchdog schedule people-finder \
    # Remove tmp files
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
