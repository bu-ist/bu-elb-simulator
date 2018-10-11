#!/bin/bash

sed -i -e "s|XX_REMOTE_URL_XX|$REMOTE_URL|g" /etc/nginx/conf.d/default.conf
sed -i -e "s|XX_DNS_RESOLVER_XX|$DNS_RESOLVER|g" /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
