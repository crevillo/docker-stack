FROM crevillo/php71
MAINTAINER The Cocktail
LABEL php.version=7.1 \
      application.type=PHP

# Add mysql client
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    php7.1-fpm \
    mysql-client \
    git \
    iputils-ping \
    telnet \
    vim \
    python-pip \
    rubygems \
    curl

ARG DOCKER_TIMEZONE=Europe/Madrid
ARG HOST_USER

RUN cp /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata


# Local user
# => to try : run container with --user option to set root user id with host user id
# -----------------------------------------------------------------------------
# nb: the 1013 used here for user id and group id is later on replaced by the code in bootstrap.sh...
RUN addgroup --gid 1013 site && \
    adduser --system --uid=1013 --gid=1013 \
        --home /home/site --shell /bin/bash site && \
    adduser site site && \
    adduser site www-data && \
    mkdir -p /home/site/.ssh; \
    cp /etc/skel/.* /home/site/; \
    chown -R site:site /home/site;

# Modify conf
RUN sed -rie 's|user = www-data|user = site|g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -rie 's|listen.owner = www-data|listen.owner = site|g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -rie 's|listen = /run/php/php7.1-fpm.sock|listen = 9000|g' /etc/php/7.1/fpm/pool.d/www.conf

# Custom PHP-FPM error log folder
RUN mkdir /var/log/php/
RUN chmod 755 -R /var/log/php/
RUN sed -rie 's|error_log = /var/log/php7.1-fpm.log|error_log = /var/log/php/php7.1-fpm.log|g' /etc/php/7.1/fpm/php-fpm.conf


# install tacoma
RUN gem install tacoma

# install node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y yarn

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 9000

CMD ["/root/bootstrap.sh"]
