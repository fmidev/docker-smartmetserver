FROM rockylinux:9.3

ARG USERNAME="smartmet-server"

ENV SMARTMET_ENV_FILE=/environment/default.env

RUN groupadd --gid 1300 htj && \
    useradd --uid 7620 --groups 1300 --gid 0 --no-create-home --system smartmet-server

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf --assumeyes install epel-release && \
    dnf --assumeyes install smartmet-tools-grid

# Demo data
COPY data/demo/demo_20240319T000000_xxx.grib2 /data/demo/demo_20240319T000000_xxx.grib2

# Default configuration
COPY conf/default.env /environment/
COPY conf/*.conf /config/filesys2smartmet/
COPY conf/*.csv /config/filesys2smartmet/

# TODO: These are copied from clients cluster
# TODO: Think whether this is a great path name
COPY conf/definitions/ /config/definitions/

USER ${USERNAME}

CMD ["filesys2smartmet", "/config/filesys2smartmet/filesys2smartmet.conf", "30"]