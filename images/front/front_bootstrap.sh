#!/bin/bash

# modify nginx vhost

mv /etc/nginx/sites-enabled/site /etc/nginx/sites-enabled/$PROJECT_NAME
sed -i -e "s/{{ project_name }}/$PROJECT_NAME/g" /etc/nginx/sites-enabled/movistar_originales
sed -i -e "s/{{ project_name }}/$PROJECT_NAME/g" /etc/nginx/sites-enabled/proxy_back

service nginx restart
service php7.1-fpm start

echo  [`date`] Bootstrapping Varnish...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service
    service varnish stop
    exit
}

echo [`date`] Starting the services...

trap clean_up SIGTERM

#fix permissions for logs folder that might be mounted on host
chmod 777 -R /var/log/varnish/

service varnish start

sleep 2

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"
