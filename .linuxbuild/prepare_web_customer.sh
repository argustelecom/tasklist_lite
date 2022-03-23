#!/bin/bash
# подменяет параметр possibleServers в конфигурационном файле build/web/assets/config/app.env
# перепаковываает архив для поставки


CUSTOMER=$1
VERSION_ARTIFACTS=$2
POSSIBLE_SERVERS=$3

cd ./build/web/assets/config
sed -i "s/^possibleServers=.*/possibleServers=$POSSIBLE_SERVERS/g" app.env
cd ../../
zip -r ../../web-$CUSTOMER-$VERSION_ARTIFACTS.zip ./*
