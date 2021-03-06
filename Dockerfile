FROM centos:7

ARG ALL_PROXY=http://192.168.10.88:1080
ARG TINI_VERSION=v0.16.1

# Install dependencies
RUN yum install -y epel-release.noarch centos-release-gluster41.noarch && \
    yum -y install \
    nfs-ganesha nfs-ganesha-xfs nfs-ganesha-vfs \
    nfs-utils rpcbind dbus && \
    # Clean cache
    yum -y clean all

# Add Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN set -x \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --verify /tini.asc \
    && rm -rf "$GNUPGHOME" /tini.asc \
    && chmod +x /tini

COPY rootfs /

VOLUME ["/data/nfs"]

# NFS ports
EXPOSE 111 111/udp 662 2049 38465-38467

ENTRYPOINT ["/tini", "--"]
CMD ["/opt/start_nfs.sh"]
