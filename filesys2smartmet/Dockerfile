FROM rockylinux:9.3

ARG USERNAME="smartmet-server"

ENV SMARTMET_ENV_FILE=/environment/default.env

#TODO remove
RUN groupadd --gid 1300 htj && \
    useradd --uid 7620 --groups 1300 --gid 0 --no-create-home --system smartmet-server

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf --assumeyes install epel-release && \
    dnf --assumeyes install smartmet-tools-grid tree

# Demo data
COPY data/demo/demo_20240319T000000_xxx.grib2 /data/demo/demo_20240319T000000_xxx.grib2

# Default configuration
COPY conf/default.env /environment/default.env
COPY conf/libraries/ /config/libraries/
COPY conf/filesys2smartmet.conf /config/filesys2smartmet.conf

USER ${USERNAME}

CMD ["filesys2smartmet", "/config/filesys2smartmet.conf", "30"]