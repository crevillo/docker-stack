#!/bin/bash

# modify nginx vhost
service nginx stop

mv /etc/nginx/sites-enabled/site /etc/nginx/sites-enabled/$PROJECT_NAME
sed -i -e "s/{{ project_name }}/$PROJECT_NAME/g" /etc/nginx/sites-enabled/$PROJECT_NAME

#service nginx restart
#service php7.1-fpm restart

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
