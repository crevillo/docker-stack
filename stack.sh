#!/usr/bin/env bash

# Script to be used instead of plain docker-compose to build and run the Docker stack

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE=${DOCKER_COMPOSE:=docker-compose}

# docker-compose already has an env var existing for this
DOCKER_COMPOSE_FILE=${COMPOSE_FILE:=docker-compose.yml}

# we allow this to come from shell env if already defined :-)
DOCKER_COMPOSE_CONFIG_FILE=${DOCKER_COMPOSE_CONFIG_FILE:=docker-compose.config.sh}


php_available_versions=(7.1)
available_web_servers=(nginx)

usage() {
    echo "Usage: ./stack.sh start|stop|rm|php_switch|web_server_switch|purgelogs|update|reset|recreate"
}

# copy template yml file to final docker-compose.yml file
buildDockerComposeFile() {
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then

        #choose which template should be used for project

        #docker_compose_template_type=${docker_compose_template_type:-nginx}
        template_file="docker-compose-template.yml"

        #if [ ! -f "$template_file" ]; then
        #    echo "ERROR: wrong template file specified. Aborting ..."
        #    exit 1;
        #fi

        echo "No $DOCKER_COMPOSE_FILE found, copying $template_file ..."
        cp "$template_file" "$DOCKER_COMPOSE_FILE"
    fi
}

buildDockerComposeLocalEnvFileIfNeeded() {
    if [ ! -f 'docker-compose.env.local' ]; then

        echo "Generating config file docker-compose.env.local ...";

        current_uid=`id -u`
        current_gid=`id -g`

        echo "DEV_UID=$current_uid" > docker-compose.env.local
        echo "DEV_GID=$current_gid" >> docker-compose.env.local

        if  [ -f 'docker-compose.config.sh' ]; then
            project_name=$(grep "export DOCKER_PROJECT_NAME=" docker-compose.config.sh | cut -c28-)
            echo "PROJECT_NAME=$project_name" >> docker-compose.env.local
        fi
    fi
}


configurePhpVersion() {
    php_version=7.1

    if [[ ! " ${php_available_versions[@]} " =~ " ${php_version} " ]]; then
        echo "ERROR: unsupported PHP version ${php_version}. Aborting ..."
        exit 1;
    fi

    # Register php version Docker env variable
    php_version='php'${php_version/./}
    if grep -q DOCKER_PHP_VERSION "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_PHP_VERSION/c\export DOCKER_PHP_VERSION='$php_version "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_PHP_VERSION=$php_version" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

   # Register php config path Docker env variable
   php_config_path="/etc/php5"

   if grep -q DOCKER_PHP_CONF_PATH "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_PHP_CONF_PATH/c\export DOCKER_PHP_CONF_PATH='$php_config_path "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_PHP_CONF_PATH=$php_config_path" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

    source $DOCKER_COMPOSE_CONFIG_FILE
    echo "Selected $php_version as PHP version"
}

configureWebServer() {
    web_server_type=nginx

    if [[ ! " ${available_web_servers[@]} " =~ " ${web_server_type} " ]]; then
        echo "ERROR: unsupported web server ${web_server_type}. Aborting ..."
        exit 1;
    fi

    # Check web_server & php combination
    if [[ "$DOCKER_PHP_VERSION" == 'php71' && "$web_server_type" != 'nginx' ]]; then
        echo "Sorry, PHP 7.1 is only available with nginx for the moment."
        echo "Current PHP version: $DOCKER_PHP_VERSION. Aborting ..."
        exit 1;
    fi

    if grep -q DOCKER_WEB_SERVER "$DOCKER_COMPOSE_CONFIG_FILE"; then
     sed -i '/DOCKER_WEB_SERVER/c\export DOCKER_WEB_SERVER='$web_server_type "$DOCKER_COMPOSE_CONFIG_FILE" ;
    else
     echo "export DOCKER_WEB_SERVER=$web_server_type" >> $DOCKER_COMPOSE_CONFIG_FILE
    fi

    echo "Selected $web_server_type as web server"
}
# Check if some files mounted as volumes exist, and create them if they are not found
checkRequiredFiles() {
     if [ ! -f ~/.gitconfig ]; then
        echo "~/.gitconfig file not found. Creating empty file"
        touch ~/.gitconfig
        if [ ! -f ~/.gitconfig ]; then
             echo "~/.gitconfig file can not be created! Aborting ..."
             exit 1;
        fi
    fi

      if [ ! -f ~/.ssh/config ]; then
        echo "~/.ssh/config file not found. Creating empty file"
        touch ~/.ssh/config
        if [ ! -f ~/.ssh/config ]; then
             echo "~/.ssh/config file can not be created! Aborting ..."
             exit 1;
        fi
    fi
}

buildDockerComposeConfigFileIfNeeded() {
    if [ ! -f "$DOCKER_COMPOSE_CONFIG_FILE" ]; then

        echo "Generando fichero de configuración $DOCKER_COMPOSE_CONFIG_FILE ...";

        read -p "[?] Cómo se llama el proyecto? " DOCKER_PROJECT_NAME
        DOCKER_PROJECT_NAME=${DOCKER_PROJECT_NAME:-myproject}

        read -p "[?] Cómo quieres que se llame la red? [$DOCKER_PROJECT_NAME] " network_name
        DOCKER_NETWORK_NAME=${network_name:-${DOCKER_PROJECT_NAME}}

        read -p "[?] Dónde tienes los archivos? [/home/$(whoami)/www]: " www_root
        www_root=${www_root:-/home/$(whoami)/www}

        if [ ! -d "$www_root" ]; then
            echo "Root directory $www_root does not exist! Aborting ..."
            exit ;
        fi

        www_dest="/var/www/$DOCKER_PROJECT_NAME/current"

        # Ask for timezone for docker args (needs docker-compsoe v2 format)
        read -p "[?] Zona horaria [Europe/Madrid]: " timezone
        timezone=${timezone:-Europe/Madrid}

        echo "Writing timezone to PHP config ..."
        echo -e "[Date]\ndate.timezone=$timezone" > config/cli/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/apache/php5/timezone.ini
        echo -e "[Date]\ndate.timezone=$timezone" > config/nginx/php/timezone.ini

        # Ask for custom vcl file path
        read -p "[?] Path to Varnish vcl file [./config/varnish/ez54.vcl]: " vcl_filepath
        vcl_filepath=${vcl_filepath:-./config/varnish/ez54.vcl}

        # Ask for tacoma file path
        read -p "[?] Dónde está tu fichero tacoma? [/home/$USER/.tacoma.yml] " tacoma_file
        tacoma_file=${tacoma_file:-/home/$USER/.tacoma.yml}

        # Save all env vars in a file that will be included at every call
        echo "# in this file we define all env variables used by docker-compose.yml" > $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_ROOT=$www_root" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_WWW_DEST=$www_dest" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_PROJECT_NAME=$DOCKER_PROJECT_NAME" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_NETWORK_NAME=$DOCKER_NETWORK_NAME" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export DOCKER_VARNISH_VCL_FILE=$vcl_filepath" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export TACOMA_FILE=$tacoma_file" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export TACOMA_PROJECT=$tacoma_project" >> $DOCKER_COMPOSE_CONFIG_FILE
        echo "export SSH_FILE=$ssh_key" >> $DOCKER_COMPOSE_CONFIG_FILE
        #Configure PHP version
        configurePhpVersion
        configureWebServer

        source $DOCKER_COMPOSE_CONFIG_FILE
    fi
}

buildNetwork() {
    echo "Creando network $DOCKER_NETWORK_NAME"
    docker network create --driver=bridge --subnet=10.0.0.0/21 $DOCKER_NETWORK_NAME
}

destroyNetwork() {
    echo "Destruyendo network $DOCKER_NETWORK_NAME"
    docker network rm $DOCKER_NETWORK_NAME
}

purgeLogs() {
    # q: why are we limiting to .log files and depth ?
    echo "Deleting existing log files:"
    find logs/ -maxdepth 2 -name "*.log*"

    find logs/ -maxdepth 2 -name "*.log*" -delete
}

update() {
    git pull
}

# ### Live code starts here ###
buildDockerComposeFile
buildDockerComposeConfigFileIfNeeded
buildDockerComposeLocalEnvFileIfNeeded
checkRequiredFiles

source $DOCKER_COMPOSE_CONFIG_FILE


case "$1" in

    start|run)
        buildNetwork

        if [ ! $DOCKER_PHP_VERSION ]; then
           configurePhpVersion
        fi

        if [ ! $DOCKER_WEB_SERVER ]; then
           configureWebServer
        fi

        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        #Always pull latest images from Docker hub
        $DOCKER_COMPOSE pull
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
        ;;

    recreate)
        buildNetwork

        if [ ! $DOCKER_PHP_VERSION ]; then
           configurePhpVersion
        fi

        if [ ! $DOCKER_WEB_SERVER ]; then
           configureWebServer
        fi

        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        #Always pull latest images from Docker hub
        $DOCKER_COMPOSE pull
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" build
        ;;

    stop)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" stop
        destroyNetwork
        ;;

    rm)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" rm --force
        ;;

    php_switch)
        configurePhpVersion
        ;;

    web_server_switch)
        configureWebServer
        ;;

    reset)
        rm $DOCKER_COMPOSE_CONFIG_FILE
        rm docker-compose.env.local
        rm $DOCKER_COMPOSE_FILE
        ;;

    purgelogs)
        purgeLogs
        ;;

    update)
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" down
        update
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" up -d
        ;;

    '')
        usage
        exit
        ;;

    *)
        # any other variation, let it go directly through to docker-compose
        $DOCKER_COMPOSE -p "$DOCKER_PROJECT_NAME" $@

esac
