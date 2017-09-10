FROM klabs/mysql
MAINTAINER The Cocktail
LABEL mysql.version=5.6

RUN cp /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
