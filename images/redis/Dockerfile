# Pull base image.
FROM ubuntu:xenial

ARG DOCKER_TIMEZONE=Europe/Madrid

# Install Redis.
RUN \
  apt-get update && \
  apt-get install -y curl gcc make vim tzdata && \
  cd /tmp && \
  curl -O http://download.redis.io/redis-stable.tar.gz && \
  tar xzvf redis-stable.tar.gz && \
  cd redis-stable && \
  make && \
  make install && \
  mkdir /etc/redis && \
  cp /tmp/redis-stable/redis.conf /etc/redis && \
  mkdir /var/lib/redis

RUN cp /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

RUN sed -i -e"s/supervised no/supervised systemd/g" /etc/redis/redis.conf && \
  sed -i -e"s/dir .\//dir \/var\/lib\/redis/g" /etc/redis/redis.conf && \
  sed -i -e"s/bind 127.0.0.1/bind 0.0.0.0/g" /etc/redis/redis.conf

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# Expose ports.
EXPOSE 6379
