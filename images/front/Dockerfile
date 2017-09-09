FROM crevillo/nginx_php71
MAINTAINER The Cocktail
LABEL varnish.version=5 \
      nginx.version=1.2 \
      php.version=7.1 \
      application.type=PHP

# add varnish

ENV TERM xterm-color

ARG DOCKER_TIMEZONE=Europe/Madrid

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    tzdata \
    curl \
    vim \
    htop \
    procps \
    net-tools;

# Configure timezone
# -----------------------------------------------------------------------------
RUN cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# varnish
# -----------------------------------------------------------------------------
RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish5/script.deb.sh | bash && \
    apt-get update && \
    apt-get install -y \
    varnish;


COPY etc/default/varnish /etc/default/varnish
COPY etc/default/varnishncsa /etc/default/varnishncsa

RUN echo "varnish:CacheMeIfYouCan" > /etc/varnish/agent_secret

COPY bootstrap.sh /root/bootstrap.sj
RUN chmod 755 /root/bootstrap.sh

# create site vhost
COPY etc/nginx/sites-enabled/site /etc/nginx/sites-enabled/$PROJECT_NAME
COPY etc/nginx/sites-enabled/proxy_back /etc/nginx/sites-enabled/proxy_back

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 6081
EXPOSE 6082

CMD ["/root/bootstrap.sh"]
