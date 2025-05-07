ARG UBUNTU_VERSION=22.04

FROM ubuntu:${UBUNTU_VERSION}

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git wget curl coreutils
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64 && chmod +x /usr/local/bin/yq
