ARG FROM_IMAGE=debian:stretch-slim
FROM $FROM_IMAGE
ARG DOCKER_TAG=base
COPY kitchen /root/kitchen/
RUN echo "Tag is [${DOCKER_TAG}]." && if [ "${DOCKER_TAG}" != "base" ]; then /bin/bash -c "export COBBLER_DOCKER_TAG=${DOCKER_TAG}; . /root/kitchen/tools/cobbler_initialize.sh;"; fi;