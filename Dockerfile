FROM alpine:latest

### Install APT packages ###
RUN apk update \
    && apk add --upgrade --no-cache \
        bash openssh curl ca-certificates openssl less htop \
		g++ make cmake ninja git wget rsync zip \
        build-base libpng-dev freetype-dev libexecinfo-dev openblas-dev libgomp lapack-dev \
		libgcc libquadmath musl  \
		gfortran libgfortran \
        graphicsmagick \
        python3 python3-dev py3-pip py3-scipy \
    && rm -rf /tmp/* /var/tmp/* /root/.cache \
	&& pip install --no-cache-dir --upgrade pip setuptools wheel

### Install PIP / Python packages ###
# Install dlib
RUN pip install dlib
# Install first requirements
RUN pip install \
        Cython numpy pybind11 pythran \
        scipy scikit-learn scikit-build opencv-python
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
