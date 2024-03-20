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

COPY data/seaheat_20240319T000000_xxx.grib2 /data/seaheat_20240319T000000_xxx.grib2

COPY conf/default.env /environment/
COPY conf/*.conf /config/
COPY conf/*.csv /config/

USER ${USERNAME}

CMD ["filesys2smartmet", "/config/default.conf", "30"]