FROM centos:7

ENV https_proxy=wwwcache.fmi.fi:8080
ENV http_proxy=wwwcache.fmi.fi:8080

LABEL maintainer "Mikko Rauhala <mikko.rauhala@fmi.fi>"

ENV NOTO_FONTS="NotoSans-unhinted NotoSerif-unhinted NotoMono-hinted" \
    GOOGLE_FONTS="Open%20Sans Roboto Lato Ubuntu" 

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
             https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm \
             # http://download.weatherproof.fi/fmiforge/rhel/7/noarch/fmiforge-release-7-1.fmi.noarch.rpm \
             # https://download.fmi.fi/smartmet-open/rhel/7/noarch/smartmet-open-release-7-2.el7.fmi.noarch.rpm \
             https://download.fmi.fi/repos/smartmet-open-fmi-17.9.1-1.el7.fmi.noarch.rpm && \
    yum -y update && yum -y install \
    	   	   smartmet-plugin-backend \
		   smartmet-plugin-admin \
		   smartmet-plugin-autocomplete \
		   smartmet-plugin-download \
		   smartmet-plugin-timeseries \
		   smartmet-plugin-wms \
		   smartmet-plugin-wfs \
		   unzip && \
    yum -y reinstall --setopt=override_install_langs='' --setopt=tsflags='' glibc-common grib_api && \
    yum clean all 

# Install Google Noto fonts
RUN mkdir -p /usr/share/fonts/truetype/noto && \
    for FONT in ${NOTO_FONTS}; \
    do \
        curl -s -S -o ${FONT}.zip https://noto-website-2.storage.googleapis.com/pkgs/${FONT}.zip && \
        unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/noto && \
        rm -f ${FONT}.zip ; \
    done

# Install Google Fonts
RUN \
    for FONT in $GOOGLE_FONTS; \
    do \
        mkdir -p /usr/share/fonts/truetype/${FONT} && \
        curl -s -S -o ${FONT}.zip "https://fonts.google.com/download?family=${FONT}" && \
        unzip -o ${FONT}.zip -d /usr/share/fonts/truetype/${FONT} && \
        rm -f ${FONT}.zip ; \
    done


HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/admin?what=qengine || exit 1

# Expose GeoServer's default port
EXPOSE 80

COPY smartmetconf /etc/smartmet
RUN mkdir -p /var/smartmet/timeseriescache /var/smartmet/imagecache
#RUN mkdir -p /smartmet/share
#COPY wms /smartmet/share/
#COPY dali /smartmet/share/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]