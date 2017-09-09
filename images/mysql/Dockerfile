FROM mysql:5.7
MAINTAINER The Cocktail
LABEL mysql.version=5.7

ARG DOCKER_TIMEZONE=Europe/Madrid

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 3306

ENTRYPOINT []
CMD ["/root/bootstrap.sh", "mysqld"]
