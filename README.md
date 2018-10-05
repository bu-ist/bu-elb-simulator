# Elastic Load Balancer Simulator

This docker image tries to simulate the behavior of Amazon ELB and can be used
to locally debug the webserver ECS containers that run behind ELB.

This image also can be used as SSL terminating proxy. By default, it will generate
a self-signed certificate for `localhost` and route the traffic to `http://localhost:8080/`.
This can be changed by setting environment variables:

Variable name | Default value
--------------|------------------------
REMOTE_URL    | http://localhost:8080/
CERT_CN       | localhost

## Usage

Using `docker-compose`:
```
version: "3.7"

services:
  elb:
    image: bostonuniversity/elb-simulator:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      REMOTE_URL: "http://http_webserver:80"
    depends_on:
      - "http_webserver"

  http_webserver:
  ...
```

### Persist generated certificate

The container checks if the file `/ssl/cert.crt` exists and regenerates the
certificate if it doesn't. This may cause issues if you're planning to install
this certificate into your OS to avoid security warnings in browsers.

Mount a volume into `/ssl` in your container. This way, even after rebuilding
the container, you'll keep using the same certificate.

Using `docker-compose`:
```
version: "3.7"

services:
  elb:
    image: bostonuniversity/elb-simulator:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      REMOTE_URL: "http://http_webserver:80"
    depends_on:
      - "http_webserver"
    volumes:
      - ./ssl:/ssl

  http_webserver:
  ...
```

### Install certificate into your OS

For Mac, run:
```
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./ssl/cert.crt
```

For Windows, double click on the `cert.crt` file, then:
```
Next > Place all certificates in the following store > Trusted Root Certificate Authorities.
```
