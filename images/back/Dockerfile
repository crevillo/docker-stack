FROM crevillo/php71
MAINTAINER The Cocktail
LABEL php.version=7.1 \
      application.type=PHP

# Add mysql client
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    mysql-client \
    git

ARG DOCKER_TIMEZONE=Europe/Madrid

RUN cp /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

EXPOSE 9000

CMD ["/bin/bash"]
