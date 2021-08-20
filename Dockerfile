FROM alpine:latest

### Install APT packages ###
RUN apk update \
    && apk add --upgrade --no-cache \
        linux-headers \
        bash openssh curl ca-certificates openssl less htop \
		g++ make cmake ninja git wget rsync zip gcc libc-dev zlib-dev \
        build-base libpng-dev freetype-dev libexecinfo-dev openblas-dev libgomp lapack-dev \
		libgcc libquadmath musl  \
		gfortran libgfortran \
        graphicsmagick jpeg-dev \
        python3 python3-dev py3-pip py3-scipy py3-numpy \
    && rm -rf /tmp/* /var/tmp/* /root/.cache \
	&& python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

### Install PIP / Python packages ###
# Install first requirements
RUN python3 -m pip install dlib Cython pybind11 pythran
# Install numpy
RUN cd ~ && \
    mkdir -p numpy && \
    git clone --single-branch https://github.com/numpy/numpy.git numpy/ && \
    cd numpy/ && \
    python3 -m pip install .
# Install other requirements
RUN python3 -m pip install scipy scikit-learn scikit-build
# Install opencv-python-headless
RUN cd ~ && \
    mkdir -p opencv-python && \
    git clone --single-branch https://github.com/skvark/opencv-python.git opencv-python/ && \
    cd opencv-python/ && \
    ENABLE_HEADLESS=1 python3 setup.py install
# Install people-finder
RUN cd ~ && \
    mkdir -p people-finder && \
    git clone --single-branch https://github.com/derogab/people-finder.git people-finder/ && \
    cd people-finder/ && \
    python3 -m pip install .
# Install last requirements
RUN python3 -m pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
