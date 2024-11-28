FROM rockylinux:8

ARG USERNAME="smartmet-server"

ENV SMARTMET_ENV_FILE=/environment/default.env

#TODO remove
RUN groupadd --gid 1300 htj && \
    useradd --uid 7620 --groups 1300 --gid 0 --no-create-home --system smartmet-server

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/8/x86_64/smartmet-open-release-latest-8.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf --assumeyes install epel-release && \
    /usr/bin/crb enable && \
    dnf --assumeyes install smartmet-tools-grid-24.9.3-1.el8.fmi.x86_64 \
        smartmet-library-macgyver-24.8.7-1.el8.fmi.x86_64 \
        smartmet-library-grid-content-24.9.3-1.el8.fmi.x86_64 \
        smartmet-library-grid-files-24.9.3-1.el8.fmi.x86_64 \
        tree

# dnf config-manager --set-enabled crb && \


# Demo data
# COPY data/demo/demo_20240319T000000_xxx.grib2 /data/demo/demo_20240319T000000_xxx.grib2

# Default configuration
COPY conf/default.env /environment/default.env
COPY conf/libraries/ /config/libraries/
COPY conf/filesys2smartmet.conf /config/filesys2smartmet.conf

USER ${USERNAME}

CMD ["filesys2smartmet", "/config/filesys2smartmet.conf", "30"]