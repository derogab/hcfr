FROM ghcr.io/dockerfast/python-scikit:latest

RUN apk update \
    # Install APT packages
    && apk add --upgrade --no-cache \
        linux-headers \
        bash openssh curl ca-certificates openssl less htop \
		g++ make cmake ninja git wget rsync zip gcc libc-dev zlib-dev \
        build-base libpng-dev freetype-dev libexecinfo-dev openblas-dev libgomp lapack-dev \
		libgcc musl  \
		gfortran libgfortran \
        graphicsmagick jpeg-dev \
        python3 python3-dev py3-pip py3-scipy py3-numpy \
    # Remove tmp files
    && rm -rf /tmp/* /var/tmp/* /root/.cache \
    # Upgrade PIP and build tools
    && python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    # Install first requirements
    && python3 -m pip install dlib Cython pybind11 pythran \
    # Build & install numpy
    && python3 -m pip install numpy \
    # Install other requirements
    && python3 -m pip install scipy scikit-learn scikit-build \
    # Build & install opencv-python-headless
    && cd ~ && \
    mkdir -p opencv-python && \
    git clone --single-branch https://github.com/skvark/opencv-python.git opencv-python/ && \
    cd opencv-python/ && \
    ENABLE_HEADLESS=1 python3 setup.py install \
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
