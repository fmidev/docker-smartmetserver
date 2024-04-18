FROM rockylinux:9.3

ARG SMARTMET_SERVER_PORT=8080
ARG USERNAME="smartmet-server"

ENV LC_ALL=fi_FI.UTF-8 \
    LANG=en_US.UTF-8

# Install FI language pack and change locale
RUN dnf --assumeyes install glibc-all-langpacks glibc-locale-source
RUN localedef -c -i fi_FI -f UTF-8 fi_FI.utf8

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf --assumeyes install https://download.fmi.fi/smartmet-private/rhel/9/x86_64/smartmet-private-release-latest-9.noarch.rpm && \
    dnf --assumeyes install https://download.fmi.fi/fmiforge/rhel/9/x86_64/fmiforge-release-latest.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf --assumeyes install epel-release && \
    dnf config-manager --setopt="epel.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="baseos.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="epel.exclude=eccodes*" --save && \
    dnf config-manager --set-disabled epel-source && \ 
    dnf --assumeyes module disable postgresql:15 && \
    dnf --assumeyes update && \
    dnf --assumeyes install --setopt=install_weak_deps=False \
    smartmet-plugin-admin \
    smartmet-plugin-autocomplete \
    smartmet-plugin-backend \
    smartmet-plugin-download \
    smartmet-plugin-edr \
    smartmet-plugin-grid-admin \
    smartmet-plugin-grid-gui \
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
    # Dependency for EDR
    smartmet-engine-observation \
    # Dependency for EDR
    smartmet-engine-querydata \
    # Dependency for EDR
    smartmet-library-delfoi \
    # Dependency for EDR
    smartmet-engine-avi \
    unzip \
    tree \
    glibc-langpack-en && \
    dnf --assumeyes reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common eccodes && \
    dnf clean all 

# Create configuration directory structure
RUN mkdir -p /config && \
    mkdir -p /config/healthcheck && \
    mkdir -p /config/engines && \
    mkdir -p /config/plugins && \
    mkdir -p /config/libraries
    
# Copy grid engine configuration
COPY conf/libraries/grid-files /config/libraries/grid-files
COPY conf/plugins/grid-gui /config/plugins/grid-gui

# create default logging directory
RUN mkdir -p /var/log/smartmet && \
    chgrp 0 /var/log/smartmet && \
    chmod g+w /var/log/smartmet

# Create grid engine directories
RUN mkdir -p /var/smartmet/grid && \
    chown ${USERNAME} /var/smartmet/grid && \
    chmod ug+w /var/smartmet/grid

# favicon is required
COPY conf/favicon.ico /config/favicon.ico

# Health check
COPY conf/smartmet_alert.sh /config/healthcheck/smartmet_alert.sh

# Copy default configuration files
COPY conf/engines /config/engines
COPY conf/libraries /config/libraries
COPY conf/plugins /config/plugins

# Change permissions for configuration
RUN chgrp --recursive 0 /config && \
    chown --recursive ${USERNAME} /config

# remove capabilities for smartmetd
RUN setcap -r /usr/sbin/smartmetd

# Demo data
COPY data/demo/demo_20240319T000000_xxx.grib2 /data/demo/demo_20240319T000000_xxx.grib2

EXPOSE ${SMARTMET_SERVER_PORT}

USER ${USERNAME}

CMD ["/usr/sbin/smartmetd"]
