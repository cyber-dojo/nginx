ARG BASE_IMAGE=nginx:1.25.3
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

ARG NGINX_DIR=/usr/share/nginx/html

RUN         apt-get update && apt-get -y upgrade
RUN         rm -rf ${NGINX_DIR}
COPY        images ${NGINX_DIR}/images
COPY        js     ${NGINX_DIR}/js
RUN chmod -R +r ${NGINX_DIR}

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
ENV COMMIT_SHA=${COMMIT_SHA}
RUN echo ${SHA} > ${NGINX_DIR}/sha.txt

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY nginx.conf.template        /docker-entrypoint.d
COPY ports.docker.env           /docker-entrypoint.d
COPY ports.k8s.env              /docker-entrypoint.d
COPY ports.ecs.env              /docker-entrypoint.d
COPY template-port-env-subst.sh /docker-entrypoint.d

COPY gzip.conf  /etc/nginx/conf.d/gzip.conf
