ARG BASE_IMAGE=nginx:stable-alpine3.17
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

ARG NGINX_DIR=/usr/share/nginx/html

RUN apk add bash
RUN apk add libcurl=8.5.0-r0        # https://security.snyk.io/vuln/SNYK-ALPINE318-CURL-6104720
RUN apk upgrade

RUN         rm -rf ${NGINX_DIR}
COPY        images ${NGINX_DIR}/images
COPY        js     ${NGINX_DIR}/js
RUN chmod -R +r ${NGINX_DIR}

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY nginx.conf.template        /docker-entrypoint.d
COPY ports.docker.env           /docker-entrypoint.d
COPY ports.k8s.env              /docker-entrypoint.d
COPY ports.ecs.env              /docker-entrypoint.d
COPY template-port-env-subst.sh /docker-entrypoint.d

COPY gzip.conf  /etc/nginx/conf.d/gzip.conf
