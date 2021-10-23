#!/bin/bash

if [ $1 == "off" ]
then
    sed -i 's/autoindex on/autoindex off/g' /etc/nginx/sites-available/localhost
    service nginx restart
elif [ $1 == "on" ]
then
   sed -i 's/autoindex off/autoindex on/g' /etc/nginx/sites-available/localhost
   service nginx restart
else
   echo "Enter [on] or [off] to change autoindex settings"
fi
