FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Ralph configuration and paths
ARG RALPH_LOCAL_DIR="/var/local/ralph"
ENV PATH=/opt/ralph/ralph-core/bin/:$PATH
ENV RALPH_CONF_DIR="/etc/ralph"
ENV RALPH_LOCAL_DIR="$RALPH_LOCAL_DIR"

# Set UTF-8 locale
RUN apt-get clean && \
    apt-get update && \
    apt-get -y install \
        apt-transport-https \
        ca-certificates \
        python3.10 \
        python3.10-dev \
        python3-pip \
        gnupg2 \
        locales \
        curl \
        wget \
        git \
        build-essential \
        libmysqlclient-dev \
        pkg-config \
        netcat-openbsd && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Ralph from package repository
RUN curl -sL https://packagecloud.io/allegro/ralph/gpgkey | apt-key add - && \
    echo 'deb https://packagecloud.io/allegro/ralph/ubuntu/ jammy main' > /etc/apt/sources.list.d/ralph.list && \
    apt-get update && \
    apt-get install -y ralph-core && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/local/ralph/media \
    /usr/share/ralph/static \
    /var/log/ralph

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/ralph

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
