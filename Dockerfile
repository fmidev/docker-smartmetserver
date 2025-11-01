FROM docker.io/rockylinux:9
LABEL maintainer "Mikko Rauhala <mikko.rauhala@fmi.fi>"
LABEL license    "MIT License Copyright (c) 2023 FMI Open Development"

ENV USER_NAME="smartmet" \
    GOOGLE_FONTS="Montserrat NotoSans OpenSans Roboto" 

RUN dnf -y install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf -y install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf -y install epel-release && \
    dnf config-manager --setopt="epel.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="baseos.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="epel.exclude=eccodes*" --save && \
    dnf config-manager --set-disabled epel-source && \ 
    dnf -y module disable postgresql:15 && \
    sed -i -e 's/^mirrorlist=/#mirrorlist=/' -e 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/rocky.repo && \
    dnf -y update && \
    dnf -y install --setopt=install_weak_deps=False \
    smartmet-plugin-admin \
    smartmet-plugin-autocomplete \
    smartmet-plugin-backend \
    smartmet-plugin-download \
    smartmet-plugin-edr \
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
    smartmet-library-tron \
    smartmet-plugin-q3 \
    lua-newcairo-q3 \
    unzip \
    glibc-langpack-en && \
    dnf -y reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common eccodes && \
    dnf clean all 

HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8080/admin?what=qengine || exit 1

# Expose SmartMet Server's default port
EXPOSE 8080

RUN mkdir -p /smartmet/data/{meps,hirlam,gfs,meteor,nam,icon,gem,gens-avg,gens-ctrl,hbm,wam,aws}/{surface,pressure} \
             /smartmet/share/wms

RUN install -m 775 -g 0 -d /var/smartmet
RUN install -m 775 -g 0 -d /var/smartmet/archivecache

RUN chmod -R g=u /etc/passwd

COPY smartmetconf /etc/smartmet
COPY share/edr /usr/share/smartmet/edr
COPY wms /smartmet/share/wms
COPY docker-entrypoint.sh /

### Containers should NOT run as root as a good practice
USER 101010

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]
