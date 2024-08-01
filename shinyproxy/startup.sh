#!/bin/bash

sed -i "s|%RE_DOCKER_IMAGE%|$RE_DOCKER_IMAGE|g" application.yml

java -jar shinyproxy.jar
