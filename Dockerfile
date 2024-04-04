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
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
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

# Bugged configuration files that are required even if disabled
COPY conf/engines/grid-engine/vff_convert.csv /config/engines/grid-engine/vff_convert.csv
COPY conf/engines/grid-engine/vff_convert.lua /config/engines/grid-engine/vff_convert.lua

# Change permissions for configuration
RUN chgrp --recursive 0 /config && \
    chown --recursive ${USERNAME} /config

# Set capabilities for smartmetd
RUN setcap 'cap_net_bind_service=' /usr/sbin/smartmetd

EXPOSE ${SMARTMET_SERVER_PORT}

USER ${USERNAME}

CMD [ "/usr/sbin/smartmetd"]