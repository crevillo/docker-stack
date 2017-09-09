Varnish 5 Docker image
=====================

This image (based on Ubuntu Xenial) runs Varnish 4.1.6 on port 6081.  
varnishncsa and varnish-agent are also installed in the container.  


How to run the container
--------------------------------

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)
* Run the container

You can run the container with the docker run command :


  ``` sh
    docker run crevillo/varnish5
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.

## How to use docker-compose to run container

First install docker-compose : 

``` sh
curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
``` 

Then run the container with the following command : 

``` sh
docker-compose up -d
``` 
