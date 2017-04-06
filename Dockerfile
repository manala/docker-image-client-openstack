FROM python:3.6.1-alpine

MAINTAINER Manala <contact@manala.io>

ARG USER_ID
ARG GROUP_ID

ENV USER_DEFAULT="client" \
    USER_ID="${USER_ID:-1000}" \
    GROUP_DEFAULT="client" \
    GROUP_ID="${GROUP_ID:-1000}"

USER root

# Packages
RUN apk add --no-cache su-exec bash

# User
RUN addgroup -g ${GROUP_ID} ${GROUP_DEFAULT} && \
    adduser -D -s /bin/sh -g ${USER_DEFAULT} -u ${USER_ID} -G ${GROUP_DEFAULT} ${USER_DEFAULT}

# Entrypoint
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

# Default command
CMD ["/bin/bash"]

# Working directory
WORKDIR /srv

# Goss
ENV GOSS_VERSION="0.3.1"
RUN apk add --no-cache --virtual=goss-dependencies curl && \
    curl -fsSL https://goss.rocks/install | GOSS_VER=v${GOSS_VERSION} sh && \
    apk del goss-dependencies

# Pip packages
ENV OPENSTACK_CLIENT="3.9.0" \
    NEUTRON_CLIENT="6.1.0" \
    SWIFT_CLIENT="3.3.0"
RUN apk add --no-cache --virtual=python-dependencies build-base linux-headers && \
    pip --no-cache-dir --disable-pip-version-check install \
      python-openstackclient==${OPENSTACK_CLIENT} \
      python-neutronclient==${NEUTRON_CLIENT} \
      python-swiftclient==${SWIFT_CLIENT} && \
    apk del python-dependencies
