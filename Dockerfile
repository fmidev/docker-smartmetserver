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
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
    unzip \
    glibc-langpack-en && \
    dnf --assumeyes reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common eccodes && \
    dnf clean all 

# favicon is required
COPY src/favicon.ico /smartmet/share/brainstorm/favicon.ico

# Set capabilities for smartmetd
RUN setcap 'cap_net_bind_service=' /usr/sbin/smartmetd

# create default logging directory
RUN mkdir -p /var/log/smartmet && \
    chgrp 0 /var/log/smartmet && \
    chmod g+w /var/log/smartmet

EXPOSE ${SMARTMET_SERVER_PORT}

USER ${USERNAME}

CMD [ "/usr/sbin/smartmetd"]