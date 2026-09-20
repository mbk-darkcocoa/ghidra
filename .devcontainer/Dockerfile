FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/ghidra-java \
    GRADLE_HOME=/usr/local/gradle \
    DISPLAY=:99

COPY Ghidra/application.properties /tmp/ghidra-application.properties
COPY .devcontainer/entrypoint.sh /usr/local/share/ghidra-devcontainer-entrypoint.sh

RUN apt-get update \
    && JAVA_VERSION="$(awk -F= '/^application.java.compiler=/{print $2}' /tmp/ghidra-application.properties)" \
    && GRADLE_VERSION="$(awk -F= '/^application.gradle.min=/{print $2}' /tmp/ghidra-application.properties)" \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        curl \
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
    && chmod +x /usr/local/share/ghidra-devcontainer-entrypoint.sh \
    && ln -sfn "$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")" /usr/lib/jvm/ghidra-java \
    && curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o /tmp/gradle.zip \
    && unzip -q /tmp/gradle.zip -d /usr/local \
    && ln -sfn "/usr/local/gradle-${GRADLE_VERSION}" /usr/local/gradle \
    && ln -sfn /usr/local/gradle/bin/gradle /usr/local/bin/gradle \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/ghidra-application.properties /tmp/gradle.zip

ENTRYPOINT ["/usr/local/share/ghidra-devcontainer-entrypoint.sh"]
