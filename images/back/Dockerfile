FROM crevillo/nginx_php71
MAINTAINER The Cocktail
LABEL varnish.version=5 \
      nginx.version=1.2 \
      php.version=7.1 \
      application.type=PHP

# Add mysql client
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    mysql-client \
    git

RUN cp /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 80
EXPOSE 81

CMD ["/root/bootstrap.sh"]
