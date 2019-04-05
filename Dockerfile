FROM quay.io/redsift/sandbox:latest
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.101

LABEL io.redsift.sandbox.install="/usr/bin/redsift/install.jl" io.redsift.sandbox.run="-J /run/sandbox/sift/sysimg.so /usr/bin/redsift/run.jl"

# Copy support files across
COPY root /

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y software-properties-common build-essential wget && \
    apt-get purge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG version=0.6.4

ENV PATH "/usr/local/julia-${version}/bin:$PATH"
RUN set -eux; \
    minor=$(echo $version | sed "s/\(.*\)\.\(.*\)\..*/\1.\2/") \
    url="https://julialang-s3.julialang.org/bin/linux/x64/${minor}/julia-${version}-linux-x86_64.tar.gz"; \
    wget -O julia.tgz "$url"; \
    tar -C /usr/local -xzf julia.tgz; \
    rm julia.tgz; \
    mv /usr/local/julia-* /usr/local/julia-$version; \
    julia -v; \
    julia -e "Pkg.add(\"JSON\");import JSON;Pkg.clone(\"https://github.com/Redsift/Nanomsg.jl\");import Nanomsg;"; \
    chown -R sandbox:sandbox $HOME/.julia

ENTRYPOINT [ "julia", "-q" ]
