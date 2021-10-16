FROM python:3-slim-stretch
# Install pre-requirements
RUN apt-get -y update && \
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
# Install dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    python3 setup.py install --yes USE_AVX_INSTRUCTIONS
# Install Cython
RUN python3 -m pip install Cython
# Install numpy
RUN cd ~ && \
    mkdir -p numpy && \
    git clone --single-branch https://github.com/numpy/numpy.git numpy/ && \
    cd numpy/ && \
    python3 setup.py install
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
    python3 setup.py install  
# Install scikit-build
RUN cd ~ && \
    mkdir -p scikit-build && \
    git clone --single-branch https://github.com/scikit-build/scikit-build.git scikit-build/ && \
    cd scikit-build/ && \
    python3 setup.py install
# Install opencv-python
RUN cd ~ && \
    mkdir -p opencv-python && \
    git clone --single-branch https://github.com/skvark/opencv-python.git opencv-python/ && \
    cd opencv-python/ && \
    python3 setup.py install
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    sed -i 's/opencv-python-headless/opencv-python/' setup.py && \
    python3 setup.py install
# Install hcfr requirements
RUN python3 -m pip install wheel setuptools python-dotenv dlib watchdog schedule people-finder
# Set working directory
WORKDIR /app
# Copy app 
COPY . .
# Run the app
CMD ["python3","-u","/app/main.py"]
