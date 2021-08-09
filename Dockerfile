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

### Install packages from sources ###
# Install dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    pip install . 
# Install Cython
RUN pip install Cython
# Install numpy
RUN cd ~ && \
    mkdir -p numpy && \
    git clone --single-branch https://github.com/numpy/numpy.git numpy/ && \
    cd numpy/ && \
    pip install . 
# Install scipy
RUN cd ~ && \
    mkdir -p scipy && \
    git clone --single-branch https://github.com/scipy/scipy.git scipy/ && \
    cd scipy/ && \
    python3 setup.py install
# Install scikit-learn
RUN cd ~ && \
    mkdir -p scikit-learn && \
    git clone --single-branch https://github.com/scikit-learn/scikit-learn.git scikit-learn/ && \
    cd scikit-learn/ && \
    pip install .
# Install scikit-build
RUN cd ~ && \
    mkdir -p scikit-build && \
    git clone --single-branch https://github.com/scikit-build/scikit-build.git scikit-build/ && \
    cd scikit-build/ && \
    pip install .
# Install opencv-python
RUN cd ~ && \
    mkdir -p opencv-python && \
    git clone --single-branch https://github.com/skvark/opencv-python.git opencv-python/ && \
    cd opencv-python/ && \
    pip install .
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    pip install .

### Install PIP / Python packages ###
RUN pip install --upgrade pip && \
    pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
