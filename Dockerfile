FROM python:3-slim

# Install APT packages
RUN apt-get update && \
    apt-get install -y cmake && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/*
# Install PIP / Python packages
RUN pip install --upgrade pip && \
    pip install python-dotenv watchdog schedule people-finder

# Set working directory
WORKDIR /app
# Copy app 
COPY . .

# Run the app
CMD ["python3","-u","/app/main.py"]
