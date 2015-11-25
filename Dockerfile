FROM ubuntu:15.10
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.101

ENV SIFT_ROOT="/run/dagger/sift" IPC_ROOT="/run/dagger/ipc"

# Fix for ubuntu to ensure /etc/default/locale is present
RUN update-locale

# Install nodejs and a minimal git + python + build tools as npm and node-gyp often needs it for modules
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:staticfloat/juliareleases && \
	apt-get update && \
	apt-get install -y julia && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy support files across
COPY root /

# Update .so cache
RUN ldconfig

RUN julia -e "Pkg.add(\"JSON\");import JSON"

VOLUME /run/dagger/sift

WORKDIR /run/dagger/sift

ENTRYPOINT [ "/usr/bin/julia", "-q" ]