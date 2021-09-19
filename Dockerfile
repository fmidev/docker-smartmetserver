FROM docker.io/centos:7
LABEL maintainer "Mikko Rauhala <mikko.rauhala@fmi.fi>"
LABEL license    "MIT License Copyright (c) 2021 FMI Open Development"

ENV USER_NAME="smartmet" \
    GOOGLE_FONTS="Lato Noto%20Sans Open%20Sans Poppins Roboto Ubuntu" 

RUN yum -y install https://download.fmi.fi/smartmet-open/rhel/7/x86_64/smartmet-open-release-21.3.26-2.el7.fmi.noarch.rpm && \
    yum -y update && \
    yum -y install epel-release && \
    yum-config-manager --setopt="epel.exclude=librsvg2*" --save && \
    yum-config-manager --setopt="base.exclude=librsvg2*" --save && \
    yum-config-manager --disable epel-source && \ 
    yum -y install \
    smartmet-plugin-backend \
    smartmet-plugin-admin \
    smartmet-plugin-download \
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
    unzip && \
    yum -y reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common eccodes && \
    yum clean all 

# Install Google Fonts
RUN \
    for FONT in $GOOGLE_FONTS; \
    do \
        mkdir -p /usr/share/fonts/truetype/${FONT} && \
        curl -s -S -o ${FONT}.zip "https://fonts.google.com/download?family=${FONT}" && \
        unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/${FONT} && \
        rm -f ${FONT}.zip ; \
    done

HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8080/admin?what=qengine || exit 1

# Expose SmartMet Server's default port
EXPOSE 8080

COPY smartmetconf /etc/smartmet
COPY wms /smartmet/share/wms
COPY docker-entrypoint.sh /

RUN mkdir -p /smartmet/data/{meps,hirlam,hirlam-knmi,gfs,icon,gem,gens-avg,gens-ctrl,hbm,wam}/{surface,pressure} \
             /smartmet/share/wms/customers

RUN mkdir -p /var/smartmet/timeseriescache /var/smartmet/imagecache /var/smartmet/querydata/validpoints && \
    chgrp -R 0 /var/smartmet/timeseriescache /var/smartmet/imagecache /var/smartmet/querydata/validpoints && \
    chmod -R g=u /var/smartmet/timeseriescache /var/smartmet/imagecache /var/smartmet/querydata/validpoints /etc/passwd /var/log

### Containers should NOT run as root as a good practice
USER 101010

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]
