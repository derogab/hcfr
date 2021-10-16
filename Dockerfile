FROM python:3

RUN apt-get -y update \
    # Prevent endless waiting
    && DEBIAN_FRONTEND=noninteractive \
    # Set UTC as timezone
    && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
    # Install APT packages
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
        python3-scipy \
        software-properties-common \
        zip \
    # Remove tmp files
    && apt-get clean && rm -rf /tmp/* /var/tmp/* \
    # Add PiWheels support
    && echo "[global]\nextra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf \
    # Upgrade PIP 
    && python3 -m pip install --no-cache-dir --upgrade pip

# Install hcfr requirements
RUN python3 -m pip install wheel setuptools Cython python-dotenv dlib watchdog schedule people-finder
# Set working directory
WORKDIR /app
# Copy app 
COPY . .
# Run the app
CMD ["python3","-u","/app/main.py"]
