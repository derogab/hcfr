FROM ghcr.io/dockerfast/python-opencv-headless:latest

RUN apt-get update \
    # Install dependencies and build tools
    && apt-get install -y --fix-missing \
        build-essential \
        cmake \
        gfortran \
        git \
        wget \
        curl \
        graphicsmagick \
        libgraphicsmagick1-dev \
        libatlas-base-dev \
        libavcodec-dev \
        libavformat-dev \
        libgtk2.0-dev \
        libjpeg-dev \
        liblapack-dev \
        libswscale-dev \
        pkg-config \
        python3-dev \
        python3-numpy \
        software-properties-common \
        zip \
    # Build & install dlib
    && cd ~ \
    && mkdir -p dlib \
    && git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git dlib/ \
    && cd  dlib/ \
    && python3 setup.py install --yes USE_AVX_INSTRUCTIONS \
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
