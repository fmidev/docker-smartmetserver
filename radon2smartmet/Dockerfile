FROM rockylinux:9.3

ARG USERNAME="smartmet-server"

ENV SMARTMET_ENV_FILE=/environment/default.env

#TODO remove
RUN groupadd --gid 1300 htj && \
    useradd --uid 7620 --groups 1300 --gid 0 --no-create-home --system smartmet-server

# Install required packages
RUN dnf --assumeyes install https://download.fmi.fi/smartmet-open/rhel/9/x86_64/smartmet-open-release-latest-9.noarch.rpm && \
    dnf --assumeyes install yum-utils && \
    dnf config-manager --set-enabled crb && \
    dnf --assumeyes install epel-release && \
    dnf --assumeyes install smartmet-tools-grid tree

COPY conf/default.env /environment/default.env
COPY conf/libraries/ /config/libraries/
COPY conf/radon-to-smartmet.cfg /config/radon-to-smartmet.cfg
COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/run.sh

ENV SMARTMET_GRID_CONFIG_FILE=/config/libraries/grid-files/grid-files.conf

CMD ["/usr/local/bin/run.sh", "30"]


