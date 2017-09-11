eZ Publish Web Development Environment
============================================================

Este repositorio provee un entorno de desarrollo para eZ Publish

## Requisitos

Está basado en Docker y require:

* Docker 1.10.0 o superior
* Docker Compose 1.6.0 o superior


*IMPORTANTE* Asegúrate de que no tienes versiones anteriores a las necesarias!

Para que funcione necesitas dejar libre los siguientes puertos en tu host:

* 82 website

## Cómo funciona

El entorno está divido en contenedores que ejecutan cada una de las partes principales.

Todos los contenedores parten de la imagen oficial de docker para ubuntu:xenial

Cada contenedor tiene un readme explicando qué instalará cada uno:

* [front](images/front/Readme.md)
* [back](images/back/Readme.md)
* [mysql](images/mysql/Readme.md)
* [redis](images/redis/Readme.md)

