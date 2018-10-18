#!/bin/bash

# Set default value for DNS_RESOLVER to the first nameserver value found in /etc/resolv.conf
if [ "$DNS_RESOLVER" = 'auto' ]; then
  export DNS_RESOLVER=$(sed -n -e 's/^.*nameserver //p' < /etc/resolv.conf | head -n 1)
fi

# Specify which environment variables to substitute
vars_to_sub='$REMOTE_URL:$DNS_RESOLVER'

# Substitute environment variables
envsubst "$vars_to_sub" < /template/nginx-default.conf > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
