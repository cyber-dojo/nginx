FROM nginx:stable-alpine3.23@sha256:15e96e59aa3b0aada3a121296e3bce117721f42d88f5f64217ef4b18f458c6ab
LABEL maintainer=jon@jaggersoft.com

RUN apk add bash tini
RUN apk upgrade

ARG NGINX_DIR=/usr/share/nginx/html
RUN      rm -rf ${NGINX_DIR}
COPY     images ${NGINX_DIR}/images
COPY     js     ${NGINX_DIR}/js
RUN chmod -R +r ${NGINX_DIR}
COPY bootstrap.sh /

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

COPY nginx.conf.template        /docker-entrypoint.d
COPY ports.docker.env           /docker-entrypoint.d
COPY ports.k8s.env              /docker-entrypoint.d
COPY ports.ecs.env              /docker-entrypoint.d
COPY template-port-env-subst.sh /docker-entrypoint.d

COPY gzip.conf  /etc/nginx/conf.d/gzip.conf

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/bootstrap.sh" ]