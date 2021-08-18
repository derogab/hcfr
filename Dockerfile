FROM jupyter/scipy-notebook:latest

### Install APT packages ###
# Need to be root to install apt packages in jupyter/scipy-notebook
USER root
# Then install all useful packages
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
# After all packages have been installed reverts to 'normal' user of jupyter/scipy-notebook
USER ${NB_UID}

### Install PIP / Python packages ###
RUN pip install --upgrade pip --use-feature=in-tree-build
# Install dlib
RUN pip install dlib --use-feature=in-tree-build
# Install first requirements
RUN pip install --use-feature=in-tree-build Cython numpy pybind11 pythran scipy scikit-learn scikit-build opencv-python --use-feature=in-tree-build
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    pip install . --use-feature=in-tree-build
# Install last requirements
RUN pip install python-dotenv watchdog schedule people-finder --use-feature=in-tree-build

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python", "-u", "/app/main.py"]
