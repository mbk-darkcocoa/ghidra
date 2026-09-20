FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/ghidra-java \
    DISPLAY=:99

COPY Ghidra/application.properties /tmp/ghidra-application.properties

RUN apt-get update \
    && JAVA_VERSION="$(awk -F= '/^application.java.compiler=/{print $2}' /tmp/ghidra-application.properties)" \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        gcc \
        g++ \
        make \
        "openjdk-${JAVA_VERSION}-jdk" \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-pip \
        python3-venv \
        unzip \
        xvfb \
        zip \
        zlib1g-dev \
        libfontconfig1 \
        libfreetype6 \
        libx11-6 \
        libxext6 \
        libxi6 \
        libxinerama1 \
        libxrandr2 \
        libxrender1 \
        libxtst6 \
    && ln -sfn "$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")" /usr/lib/jvm/ghidra-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/ghidra-application.properties
