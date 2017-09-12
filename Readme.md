eZ Publish Web Development Environment
============================================================

This repository provides a Docker stack management script and docker-compose.yml templates needed to create and use an eZ Publish Development Environment.

It's forked from [Kaliop eZ Publish web development environment](https://github.com/kaliop/ezdocker-stack).

It is to be used in conjunction with another repository which will contain the Application source code. The Application source code can be installed in the 'site' directory within the Development Environment root directory, or in your local main projects directory (~/www for example).

All Docker images used in this stack are published on Docker hub, in crevillo repository.

The development environment is based on Docker containers and requires:

Docker 1.10.0 or later
Docker Compose 1.6.0 or later
IMPORTANT make sure your installed versions of Docker and Docker Compose are not older than the required ones!

For MacOSX and Windows users, the recommended setup is to use a Debian or Ubuntu VM as host for the containers (remember to make the current user a member of 'docker' group). NB: give at least 2GB of RAM to the host VM, as it is necessary when running Composer...

The following ports have to be not in use on the host machine:

* 80 website

## How it works

The environment is split into containers which execute each one of the main services.

All containers are built from the ubuntu xenail official docker image as this should reflect the software stack installed on the staging and Production environments.

Each container image has a Readme file describing it in detail, in the same folder as the image:

* [front](images/front/Readme.md)
* [back](images/back/Readme.md)
* [mysql](images/mysql/Readme.md)
* [redis](images/redis/Readme.md)
* [haproxy](images/haproxy/Readme.md)

The front container provides two vhost attached to specific domain name patterns :

ez5 virtual host (*.dev.{{ project_name }}) : This project_name will be asked to you on first run.

Two vhost will be added to /etc/nginx/sites-enabled. One for defining a proxy, the other to work with ez.
They are copied and then modified from [images/front/etc/nginx/sites-enabled](images/front/etc/nginx/sites-enabled)

Front container will also have a varnish installation listening on port 6081. Vcl is the one provided
by ezplatform. 

Back container will have php-fpm listening on port 9000.


1. Install Docker and Docker Compose

    Follow the instructions appropriate to your OS.
    F.e. for Ubuntu linux:

    [https://docs.docker.com/engine/installation/ubuntulinux/](https://docs.docker.com/engine/installation/ubuntulinux/)
    
    [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
    

2. Clone the Docker stack Repository

    Most of the files needed to get the environment going are located in this repository with the exception of the app codebase,
    which is stored in another repository and will have to be installed separately once the environment is configured, 
    and some docker images which are also stored in other repositories and imported as git sub modules. 

    To get the required files onto the host machine simply clone this repo into a local folder :

        git clone https://github.com/crevillo/docker-stack.git
        cd /path/to/your/docker/folder/docker-stack
    

3. Environment Settings

    Note that all the required environment variables are already set in [docker-compose.env](docker-compose.env), only
    set in  `docker-compose.env.local` the value of any that you need to change.

    * If the user-id and group-id you use on the host machine are not 1000:1000, the stack shell script will set these information automatically in `docker-compose.env.local` file.  
        This will help with avoiding filesystem permissions later on with the web server container mount points.
        To find out the id of the current user/group on the host machine, execute the `id` command.  

    * The MySQL settings are already configured in the eZ Publish environment and on first run an empty database will be
        created ready for you to import the required data as outlined in the setup instructions in the eZPublish repository.
        
    The `docker-compose.config.sh` file contains your project specific settings. It will be generated on first launch but feel free to edit them manually if you need to.

5. Make sure that the config/*, logs/* and data/* subfolders can be written to.

    Some of the containers (currently this includes front and back) will write log files and data files to those
    directories on the host using a different user/group than the one you are using. You have to make sure that those
    files can be written. In doubt, run:

        find ./config -type d -exec chmod 777 {} \; && find ./data -type d -exec chmod 777 {} \; && find ./logs -type d -exec chmod 777 {} \;


6. Launch the stack script and configure your stack

	The docker stack provides a shell script to manage your project's docker-compose file.
	The script is interactive and will ask you a few questions to configure your project the first time you run it.
	Once this is done, `docker-compose.env.local`, `docker-compose.config.sh` and `docker-compose.yml` files will be created in the main folder.
	
	Here are the information you will need to enter in your console to configure your project : 
	
	* Your project name
    * The name of the network you want to create. This will create a private network using a range of ips. you 
    can connect from one container to the other using it. for example, to tell back container to connect to mysql container
    you can use db.{{ name of network you have added }
	* the path where you have the project in your host
	* Your current timezone
	* The path to your tacoma file. that file will be added to the back container so you can connect amazon from it
	* The path to your ssh keys. This path will be also copied to the back container so you can connect to github and 
	probably other things from it.
	
	The ezdocker stack uses Docker images from [crevillo Repository](https://hub.docker.com/u/crevillo/)
    These images will be downloaded the first time you start the stack, and will be updated if needed each time you start the stack.

7. Set up the Application

    Follow the instructions in the Readme file of the application (*nb:* you will most likely have to start the
    containers for that, please read below for instructions)


## Starting the Environment

You can use the `stack.sh` script to start/stop the development environment.

The script will perform the following operations:

1. Stop all running docker containers
2. Start Docker Compose which will start all the containers.

Before running the environment for the first time please verify that the settings are correct for your user and group ids in docker-compose.env.local.

To start the run script navigate to the project folder and run:

    ./stack.sh run or ./stack.sh start

## Updating the Environment

To pull in the latest changes and restart all the containers, just run:

    ./stack.sh update

*NB:* this will apply any changes coming from the git repository which contains the definition of the stack, but it
will not update the base Docker images in use. 

## Changing the environment configuration

The stack configuration is mainly managed by the `docker-compose.yml` file, which is ignored in GIT.
You can therefore edit this file and make all the changes you need for your project, like adding volumes, adding or removing containers...

### Websites

To use hostname-based vhosts, you should edit the local hosts file of the computer you are using.
All hostnames used to point to 127.0.0.1 will trigger the same Apache Vhost.

Port 80 is mapped to haproxy server. By default, haproxy will server your pages directly through Nginx, but you can choose whether you want to view your website via Varnish or not.  
To do this, you must send a specific header called `Backend` and set the desired value : 

### Connecting to the back container (for clearing caches, running composer-install, etc...)

While you can edit files directly from your host, and you can even use your php and composer from it, you can 
also enter the back container and do all operations from that. You can also edit files from it. 
To do this, you can enter the container executing

    docker exec -ti back su site
    
The `su site` part is to enter the container with that user, as the user is the owner of the project files in the container.

## Stopping the Environment

    ./stack.sh down
    
## Deleting all containers

    ./stack.sh rm
    
## Reset all environment configuration

    ./stack.sh reset    

This will delete `docker-compose.env.local`, `docker-compose.config.sh` and `docker-compose.yml` files.
The script will ask you for project configuration on next run.
    
## Recreate all images

    ./stack.sh recreate
    
If you want to modify one of the images you can modify your `docker-compose.yml` file and tell the service
to search for the image directly on your disk. This is useful for testing. By default images are got from 
Docker hub and regenerated in every push to this repo, but the generation can take some time. 

For instance, if you want to modify something in the front container, you can edit Dockerfile in that image
and then modify your docker-composer.yml like
```
services:
    front1:
        build:
            context: images/front
```      

See docker-compose doc for more info.            


## Extras

### Connecting to a running container (run a shell session)

List the Ids of all running containers:

    docker ps

Note down id of the container you want to connect to, then run:

    docker exec -it <container-name> bash

Note: do *not* use `docker run` to attach to an existing container, as that will in fact spawn a new container.

Note: to connect to the back containers, use `su site` instead of `bash`


### Checking the status of all existing containers (not only the active ones)

    docker ps -a

### Fixing user permissions

If you connect to back container to execute commands such as `git pull` or `composer update`, take care: by default
you will be connecting as the root user. Any files written by the root user might be problematic because they will not
be modifiable by the nginx webserver user.
Is is thus a better idea to connect to the web server container as the *site* user (used to run nginx).

If you have problems with user permissions, just run `sudo chmod -R <localuser>:<localgroup> site` on the host machine,
with the appropriate ids for localuser and localgroup.

### Removing a local image

In case things are horribly wrong:

    docker ps -a
    docker rm <id of the container>
    docker rmi <id of the image>

### Cleaning up orphaned images from your hard disk

Note that when you delete images used by containers, as shown above, you will not be deleting all docker image layers
from your hard disk. To check it out, just run `docker images`...

The best tool we found so far to really clean up leftover image layers is: https://github.com/spotify/docker-gc
