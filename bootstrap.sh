#!/usr/bin/env bash
set -Eeu

# Dockerfile has this

# ARG BASE_IMAGE=nginx:stable-alpine3.17
# FROM ${BASE_IMAGE}
# RUN apk add tini
# ...
# ENTRYPOINT ["/sbin/tini", "-g", "--"]
# CMD [ "/bootstrap.sh" ]

# This ENTRYPOINT will overwrite the ENTRYPOINT in the
# base image. So we need /bootstrap.sh to repeat the
# base image's ENTRYPOINT and CMD, which we can find using:
#
# $ docker inspect nginx:stable-alpine3.17
#
# Which gives this output...
#
# [
#   {
#      "Config":
#      {
#         ...
#        "Cmd": [
#            "nginx",
#            "-g",
#            "daemon off;"
#        ],
#        ...
#        "Entrypoint": [
#            "/docker-entrypoint.sh"
#        ],
#        ...
#     }
# ]
#

/docker-entrypoint.sh nginx -g "daemon off;"