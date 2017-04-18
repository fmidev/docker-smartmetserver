FROM centos:7
LABEL maintainer "Mikko Rauhala <mikko.rauhala@fmi.fi>"

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
             https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm \
             http://download.weatherproof.fi/fmiforge/rhel/7/noarch/fmiforge-release-7-1.fmi.noarch.rpm \
	     http://smartmet:SmartMetFMI@download.weatherproof.fi//smartmet-base/rhel/7/noarch/smartmet-release-7-1.el6.fmi.noarch.rpm && \
    yum -y update && yum -y install \
    	   	   smartmet-server \
		   smartmet-plugins-admin \
		   smartmet-plugins-download \
		   smartmet-plugins-timeseries \
		   smartmet-plugins-wms && \
    yum clean all



HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/admin?what=qengine || exit 1

# Expose GeoServer's default port
EXPOSE 80

COPY smartmetconf /etc/smartmet
#RUN mkdir -p /smartmet/share
#COPY wms /smartmet/share/
#COPY dali /smartmet/share/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]
