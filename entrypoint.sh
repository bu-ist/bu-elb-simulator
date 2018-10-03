#!/bin/bash

envsubst '$CERT_CN' < /template/cert.conf > /ssl/cert.conf

if [ ! -f /ssl/cert.crt ]; then
  openssl genrsa -out /ssl/cert.key 2048
  openssl rsa -in /ssl/cert.key -out /ssl/cert.key.rsa
  openssl req -new -key /ssl/cert.key.rsa -subj /CN=$CERT_CN -out /ssl/cert.csr -config /ssl/cert.conf
  openssl x509 -req -extensions v3_req -days 3650 -in /ssl/cert.csr -signkey /ssl/cert.key.rsa -out /ssl/cert.crt -extfile /ssl/cert.conf
fi

# Run command
exec "$@"
