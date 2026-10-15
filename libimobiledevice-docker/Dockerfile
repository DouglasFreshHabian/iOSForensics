FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# Build configuration
# ---------------------------------------------------------------------------

ENV PREFIX=/opt/libimobiledevice
ENV PATH="/root/.local/bin:/opt/pymobiledevice3Env/bin:/opt/libimobiledevice/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/libimobiledevice/lib"
ENV PKG_CONFIG_PATH="/opt/libimobiledevice/lib/pkgconfig"

# ---------------------------------------------------------------------------
# Build dependencies and required tools
# ---------------------------------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    git \
    autoconf \
    automake \
    libtool-bin \
    libssl-dev \
    libcurl4-openssl-dev \
    libreadline-dev \
    ca-certificates \
    fish \
    python3 \
    python3-venv \
    python3-pip \
    pipx \
    sqlite3 \
    libusb-1.0-0 \
    curl \
    adb \
    usbutils \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Build libimobiledevice stack from upstream source
# ---------------------------------------------------------------------------

WORKDIR /tmp

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libplist.git; \
    cd libplist; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp; \
    rm -rf libplist

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libimobiledevice-glue.git; \
    cd libimobiledevice-glue; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp; \
    rm -rf libimobiledevice-glue

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libusbmuxd.git; \
    cd libusbmuxd; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp; \
    rm -rf libusbmuxd

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libtatsu.git; \
    cd libtatsu; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp; \
    rm -rf libtatsu

RUN set -eux; \
    git clone --depth 1 https://github.com/libimobiledevice/libimobiledevice.git; \
    cd libimobiledevice; \
    ./autogen.sh --prefix="$PREFIX"; \
    make -j"$(nproc)"; \
    make install; \
    cd /tmp; \
    rm -rf libimobiledevice

# ---------------------------------------------------------------------------
# Configure runtime libraries
# ---------------------------------------------------------------------------

RUN echo "/opt/libimobiledevice/lib" \
        > /etc/ld.so.conf.d/libimobiledevice.conf \
 && ldconfig

# ---------------------------------------------------------------------------
# Install pymobiledevice3 in a virtual environment
# ---------------------------------------------------------------------------

RUN set -eux; \
    python3 -m venv /opt/pymobiledevice3Env; \
    /opt/pymobiledevice3Env/bin/python3 -m pip install --upgrade pip; \
    /opt/pymobiledevice3Env/bin/python3 -m pip install --upgrade pymobiledevice3

# ---------------------------------------------------------------------------
# Install Mobile Verification Toolkit (MVT) with pipx
# ---------------------------------------------------------------------------

RUN pipx install mvt

# ---------------------------------------------------------------------------
# Install Android Quick Forensics (androidqf)
# ---------------------------------------------------------------------------

ARG ANDROIDQF_VERSION=1.8.3

RUN set -eux; \
    curl -fL --retry 3 \
      "https://github.com/mvt-project/androidqf/releases/download/v${ANDROIDQF_VERSION}/androidqf_linux_amd64_${ANDROIDQF_VERSION}" \
      -o /usr/local/bin/androidqf; \
    chmod 755 /usr/local/bin/androidqf

# ---------------------------------------------------------------------------
# Shell configuration
# ---------------------------------------------------------------------------

WORKDIR /root

CMD ["/bin/bash"]
