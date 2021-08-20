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
	&& pip install --no-cache-dir --upgrade pip setuptools wheel

### Install PIP / Python packages ###
# Install dlib
RUN pip install dlib
# Install first requirements
RUN pip install \
        Cython pybind11 pythran \
        scipy scikit-learn scikit-build
# Install numpy
RUN cd ~ && \
    mkdir -p numpy && \
    git clone --single-branch https://github.com/numpy/numpy.git numpy/ && \
    cd numpy/ && \
    python3 setup.py install
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
    pip install .
# Install last requirements
RUN pip install python-dotenv watchdog schedule people-finder

### Load app ###
# Set working directory
WORKDIR /app
# Copy app 
COPY . .

### Run the app ###
CMD ["python3", "-u", "/app/main.py"]
