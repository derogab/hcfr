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
# Install dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    pip install . 
# Install Cython
RUN pip install Cython
# Install numpy
RUN pip install numpy 
# Install pybind11
RUN pip install pybind11
# Install scipy
RUN cd ~ && \
    mkdir -p scipy && \
    git clone --single-branch https://github.com/scipy/scipy.git scipy/ && \
    cd  scipy/ && \
    python setup.py install 
# Install scikit-learn
RUN pip install scikit-learn
# Install scikit-build
RUN pip install scikit-build
# Install opencv-python
RUN pip install opencv-python
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    pip install .

RUN pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python", "-u", "/app/main.py"]
