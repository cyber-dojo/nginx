ARG BASE_IMAGE=nginx:stable-alpine3.19
FROM ${BASE_IMAGE}
# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

LABEL maintainer=jon@jaggersoft.com

ARG NGINX_DIR=/usr/share/nginx/html

RUN apk add tini
RUN apk add bash
RUN apk add libexpat=2.6.3-r0  # https://security.snyk.io/vuln/SNYK-ALPINE319-EXPAT-7908399

RUN apk upgrade

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