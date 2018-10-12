# Elastic Load Balancer Simulator

This docker image tries to simulate the behavior of Amazon ELB and can be used
to locally debug the webserver ECS containers that run behind ELB.

This image also can be used as SSL terminating proxy. By default, it will generate
a self-signed certificate for `localhost` and route the traffic to `http://localhost:8080/`.
This, along with other options, can be changed by setting environment variables.


## Environment Variables

Variable name | Default value
--------------|------------------------
REMOTE_URL    | http://localhost:8080/
CERT_CN       | localhost
DNS_RESOLVER  | 127.0.0.11


## Sample Usage

#### Using `docker`

The command below assumes that you have a local webserver running on port 5000
but you want to be able to access it via 
either http://localhost or https://localhost instead.
```
docker run --rm -p 443:443 -p 80:80 -e REMOTE_URL=http://host.docker.internal:5000 bostonuniversity/elb-simulator:latest
```

#### Using `docker-compose`

The config below assumes that you have a service named `http_webserver`
running on port 8000 but you want to be able to access it via 
either http://localhost or https://localhost instead.
```
version: "3.7"

services:
  elb:
    image: bostonuniversity/elb-simulator:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      REMOTE_URL: "http://http_webserver:8000"
    depends_on:
      - "http_webserver"

  http_webserver:
  ...
```


## Troubleshooting

#### Missing Resolver

Sometimes, you may see something like this in the ouput:

> recv() failed (111: Connection refused) while resolving, resolver: 127.0.0.11:53

This most likely indicates that the DNS resolver doesn't exist on the default address (127.0.0.11).
There are two possible remedies in this situation:

1. Use the DNS resolver that was configured for your container.
    To find the address of the resolver, run: 
    ```
    docker run --rm bostonuniversity/elb-simulator:latest cat /etc/resolv.conf
    ```

    In the output, find the line that starts with `nameserver`
    and then pass that IP as the `DNS_RESOLVER` environment variable to the container:
    ```
    docker run --rm -p 443:443 -p 80:80 -e REMOTE_URL=http://host.docker.internal:5000 -e DNS_RESOLVER=192.168.100.1 bostonuniversity/elb-simulator:latest
    ```

1. Force the creation of the DNS resolver on 127.0.0.11 
    by running your docker container inside the custom network.
    First, create the network:
    ```
    docker network create local
    ```

    Then, pass it as `--net` parameter when running the container:
    ```
    docker run --rm -p 443:443 -p 80:80 -e REMOTE_URL=http://host.docker.internal:5000 --net=local bostonuniversity/elb-simulator:latest
    ```


## Persist generated certificate

The container checks if the file `/ssl/cert.crt` exists and regenerates the
certificate if it doesn't. This may cause issues if you're planning to install
this certificate into your OS to avoid security warnings in browsers.

Mount a volume into `/ssl` in your container. This way, even after rebuilding
the container, you'll keep using the same certificate.

#### Using `docker`

```
docker run --rm -p 443:443 -p 80:80 -e REMOTE_URL=http://host.docker.internal:5000 -v $(pwd)/ssl:/ssl bostonuniversity/elb-simulator:latest
```

#### Using `docker-compose`

```
version: "3.7"

services:
  elb:
    image: bostonuniversity/elb-simulator:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      REMOTE_URL: "http://http_webserver:8000"
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
