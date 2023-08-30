FROM docker.io/rockylinux:8
LABEL maintainer "Mikko Rauhala <mikko.rauhala@fmi.fi>"
LABEL license    "MIT License Copyright (c) 2023 FMI Open Development"

ENV USER_NAME="smartmet" \
    GOOGLE_FONTS="Lato Noto%20Sans Open%20Sans Poppins Roboto Ubuntu" 

RUN dnf -y install https://download.fmi.fi/smartmet-open/rhel/8/x86_64/smartmet-open-release-latest-8.noarch.rpm && \
    dnf -y install yum-utils epel-release && \
    /usr/bin/crb enable && \
    dnf config-manager --setopt="epel.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="base.exclude=librsvg2*" --save && \
    dnf config-manager --setopt="epel.exclude=eccodes*" --save && \
    dnf config-manager --set-disabled epel-source && \ 
    dnf -y update && \
    dnf -y install \
    smartmet-plugin-admin \
    smartmet-plugin-autocomplete \
    smartmet-plugin-backend \
    smartmet-plugin-download \
    smartmet-plugin-edr \
    smartmet-plugin-timeseries \
    smartmet-plugin-wms \
    smartmet-engine-grid \
    unzip && \
    dnf -y reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common eccodes && \
    dnf clean all 

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

RUN mkdir -p /smartmet/data/{meps,hirlam,gfs,meteor,nam,icon,gem,gens-avg,gens-ctrl,hbm,wam}/{surface,pressure} \
             /smartmet/share/wms

RUN install -m 775 -g 0 -d /var/smartmet

RUN chmod -R g=u /etc/passwd

COPY smartmetconf /etc/smartmet
COPY wms /smartmet/share/wms
COPY docker-entrypoint.sh /

### Containers should NOT run as root as a good practice
USER 101010

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]
