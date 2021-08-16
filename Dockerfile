FROM python:3

### Install APT packages ###
RUN apt-get update && \
    apt-get install -y --fix-missing \
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
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

### Install PIP / Python packages ###
RUN pip install --upgrade pip
# Build & install dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    pip install . 
# Install scipy requirements
RUN pip install Cython numpy pybind11 pythran
# Install scipy
RUN pip install scipy
# Install other requirements
RUN pip install scikit-learn scikit-build opencv-python
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    pip install .
# Install last requirements
RUN pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python", "-u", "/app/main.py"]
