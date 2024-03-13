FROM rockylinux:9.3

ARG SMARTMET_SERVER_PORT=8080
ARG USERNAME="smartmet-server"

RUN groupadd --gid 1300 htj
RUN useradd --uid 7620 --no-create-home --gid 1300 --shell /sbin/nologin smartmet-server

COPY src/docker-entrypoint.sh /docker-entrypoint.sh

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


# RUN install -m 775 -g 0 -d /var/smartmet

# RUN chmod -R g=u /etc/passwd

# konffit
# backend
# - sputnik fmi gitissä (generoidaan tai gitistä?)
# - etc/smartmet/smartmet.env määritellään käynnistys & portit yms systemd:lle --optiot
#  -c = CONFIGFILE=/smartmet/cnf/smartmetd/clients/backend.conf
# frontent

#configmap -> config tiedosto -> ajokomennolle

#redis omana konffina

RUN mv /usr/sbin/smartmetd /usr/bin/smartmetd

EXPOSE ${SMARTMET_SERVER_PORT}

USER ${USERNAME}

ENTRYPOINT ["/docker-entrypoint.sh"]

