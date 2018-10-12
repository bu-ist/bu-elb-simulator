#!/bin/bash

# Specify which environment variables to substitute
vars_to_sub='$REMOTE_URL:$DNS_RESOLVER'

# Substitute environment variables
envsubst "$vars_to_sub" < /template/nginx-default.conf > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
