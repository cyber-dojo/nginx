#!/usr/bin/env bash
set -Eeu

# Dockerfile has this

# FROM nginx:stable-alpine3.20@sha256:1eadbb07820339e8bbfed18c771691970baee292ec4ab2558f1453d26153e22d
# RUN apk add tini
# ...
# ENTRYPOINT ["/sbin/tini", "-g", "--"]
# CMD [ "/bootstrap.sh" ]

# This ENTRYPOINT will overwrite the ENTRYPOINT in the
# base image. So we need /bootstrap.sh to repeat the
# base image's ENTRYPOINT and CMD, which we can find using:
#
# $ docker inspect nginx:stable-alpine3.20@sha256:1eadbb07820339e8bbfed18c771691970baee292ec4ab2558f1453d26153e22d
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