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
    mysql-client

EXPOSE 80
EXPOSE 81
