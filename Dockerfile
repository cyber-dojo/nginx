FROM nginx:stable-alpine3.20@sha256:1eadbb07820339e8bbfed18c771691970baee292ec4ab2558f1453d26153e22d
LABEL maintainer=jon@jaggersoft.com

RUN apk add bash tini
RUN apk upgrade

RUN apk add --upgrade expat=2.7.4-r0      # https://security.snyk.io/vuln/SNYK-ALPINE321-EXPAT-15199474
RUN apk add --upgrade busybox=1.36.1-r31  # https://security.snyk.io/vuln/SNYK-ALPINE320-BUSYBOX-14102403
RUN apk add --upgrade libxml2=2.12.10-r0  # https://security.snyk.io/vuln/SNYK-ALPINE320-LIBXML2-10165474
RUN apk upgrade musl                      # https://security.snyk.io/vuln/SNYK-ALPINE320-MUSL-8720638

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