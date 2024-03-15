FROM rockylinux:9.3

ARG USERNAME="smartmet-server"

RUN groupadd --gid 1300 htj && \
    useradd --uid 7620 --groups 1300 --gid 0 --no-create-home --system smartmet-server

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf --assumeyes install epel-release && \
    dnf --assumeyes install smartmet-tools-grid

USER ${USERNAME}
