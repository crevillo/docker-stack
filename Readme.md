eZ Publish Web Development Environment
============================================================

This repository provides a Docker stack management script and docker-compose.yml templates needed to create and use an eZ Publish Development Environment.

It is to be used in conjunction with another repository which will contain the Application source code. The Application source code can be installed in the 'site' directory within the Development Environment root directory, or in your local main projects directory (~/www for example).

All Docker images used in this stack are published on Docker hub, in crevillo repository.

The development environment is based on Docker containers and requires:

Docker 1.10.0 or later
Docker Compose 1.6.0 or later
IMPORTANT make sure your installed versions of Docker and Docker Compose are not older than the required ones!

For MacOSX and Windows users, the recommended setup is to use a Debian or Ubuntu VM as host for the containers (remember to make the current user a member of 'docker' group). NB: give at least 2GB of RAM to the host VM, as it is necessary when running Composer...

The following ports have to be not in use on the host machine:

* 82 website

## How it works

The environment is split into containers which execute each one of the main services.

All containers are built from the ubuntu xenail official docker image as this should reflect the software stack installed on the staging and Production environments.

Each container image has a Readme file describing it in detail, in the same folder as the image:

* [front](images/front/Readme.md)
* [back](images/back/Readme.md)
* [mysql](images/mysql/Readme.md)
* [redis](images/redis/Readme.md)

The front container provides two vhost attached to specific domain name patterns :

ez5 virtual host (*.dev.{{ project_name }}) : This project_name will be asked to you on first run.

1. Install Docker and Docker Compose

    Follow the instructions appropriate to your OS.
    F.e. for Ubuntu linux:

    [https://docs.docker.com/engine/installation/ubuntulinux/](https://docs.docker.com/engine/installation/ubuntulinux/)
    
    [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
    

3. Clone the Docker stack Repository

    Most of the files needed to get the environment going are located in this repository with the exception of the app codebase,
    which is stored in another repository and will have to be installed separately once the environment is configured, 
    and some docker images which are also stored in other repositories and imported as git sub modules. 

    To get the required files onto the host machine simply clone this repo into a local folder :

        git clone https://github.com/crevillo/docker-stack.git
        cd /path/to/your/docker/folder/docker-stack
    

4. Environment Settings

    Note that all the required environment variables are already set in [docker-compose.env](docker-compose.env), only
    set in  `docker-compose.env.local` the value of any that you need to change.

    * If the user-id and group-id you use on the host machine are not 1000:1000, the stack shell script will set these information automatically in `docker-compose.env.local` file.  
        This will help with avoiding filesystem permissions later on with the web server container mount points.
        To find out the id of the current user/group on the host machine, execute the `id` command.  

    * The MySQL settings are already configured in the eZ Publish environment and on first run an empty database will be
        created ready for you to import the required data as outlined in the setup instructions in the eZPublish repository.
        
    The `docker-compose.config.sh` file contains your project specific settings. It will be generated on first launch but feel free to edit them manually if you need to.
