FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 \
    DISPLAY=:99

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        gcc \
        g++ \
        make \
        openjdk-21-jdk \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
