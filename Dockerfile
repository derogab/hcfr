FROM ghcr.io/dockerfast/python-opencv-headless:latest

RUN apt-get update \
    # Prevent endless waiting
    && DEBIAN_FRONTEND=noninteractive \
    # Set UTC as timezone
    && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
    # Install APT packages
    && apt-get install -y --fix-missing \
        build-essential \
        make \
        cmake \
        g++ \
        cpp \
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
        python3-numpy-dev \
        python3-scipy \
        software-properties-common \
        zip \
    # Remove tmp files
    && apt-get clean && rm -rf /tmp/* /var/tmp/* \
    # Upgrade PIP and build tools
    && python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    # Install requirements
    && python3 -m pip install --no-cache-dir \
        dlib cython pybind11 pythran \
        numpy scipy scikit-learn scikit-build \
	opencv-python-headless \
    # Build & install people-finder
    && cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    python3 -m pip install . \
    # Install last requirements
    && python3 -m pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
