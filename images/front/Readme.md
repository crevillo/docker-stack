# Front web server

This container runs the Nginx & php-fpm services and also varnish.

Image is built on Ubuntu Xenial.

The main software packages installed are:

* Nginx 1.2
* PHP 7.1
* Varnish 5

## Nginx config

Nginx listens on ports:
* 80

Varnish listens on ports:
* 6081

Those can be remapped when running the container.

## How to run the container

* If you are working behind a corporate http proxy, run [the klabs/forgetproxy container](https://registry.hub.docker.com/u/klabs/forgetproxy/)

* Run the container

You can run the container with the docker run command :


	``` sh
    docker run crevillo/front
    ```

 But is is strongly recommended to use docker-compose with the stack.sh script provided in [ezdocker-stack](https://github.com/kaliop/ezdocker-stack/) repository.
