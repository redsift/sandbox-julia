FROM quay.io/redsift/sandbox:latest
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.101

LABEL io.redsift.sandbox.install="/usr/bin/redsift/install" io.redsift.sandbox.run="/usr/bin/redsift/run"

# Copy support files across
COPY root /

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y software-properties-common build-essential wget && \
    apt-get purge -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG version=1.0.0

ENV PATH "/usr/local/julia-${version}/bin:$PATH"
RUN set -eux; \
    minor=$(echo $version | sed "s/\(.*\)\.\(.*\)\..*/\1.\2/") \
    url="https://julialang-s3.julialang.org/bin/linux/x64/${minor}/julia-${version}-linux-x86_64.tar.gz"; \
    wget -q -O julia.tgz "$url"; \
    tar -C /usr/local -xzf julia.tgz; \
    rm julia.tgz; \
    julia -v; \
    julia -e 'import Pkg;Pkg.add(Pkg.Types.PackageSpec(url="https://github.com/Redsift/Nanomsg.jl", rev="master")); Pkg.add("JSON");Pkg.add("PackageCompiler");import JSON;import Nanomsg;'; \
    chown -R sandbox:sandbox /usr/local/julia-$version; \
    chown -R sandbox:sandbox $HOME/.julia

ENTRYPOINT [ "/bin/bash" ]
