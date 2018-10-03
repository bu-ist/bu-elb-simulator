FROM nginx:1.13

ENV REMOTE_URL="http://localhost:8080/"
ENV CERT_CN="localhost"

RUN apt-get update
RUN apt-get install openssl -y

RUN mkdir /template

COPY cert.conf /template/cert.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/run.sh"]
