FROM python:3-slim

# Install APT packages
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
        zip && \ 
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/*
# Install PIP / Python packages
RUN python3 -m pip install wheel setuptools 
RUN python3 -m pip install Cython
RUN python3 -m pip python-dotenv dlib watchdog schedule people-finder

# Set working directory
WORKDIR /app
# Copy app 
COPY . .

# Run the app
CMD ["python3","-u","/app/main.py"]
