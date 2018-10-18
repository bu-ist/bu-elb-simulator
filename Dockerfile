FROM nginx:1.13

ENV REMOTE_URL=""
ENV CERT_CN="localhost"
ENV DNS_RESOLVER="auto"

RUN apt-get update
RUN apt-get install openssl -y

RUN mkdir /template
RUN mkdir /ssl

COPY cert.conf /template/cert.conf
COPY nginx-default.conf /template/nginx-default.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/run.sh"]
