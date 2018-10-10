FROM debian:stretch-slim
ARG DOCKER_TAG	
ENV COBBLER_DOCKER_TAG=$DOCKER_TAG
COPY kitchen /root/kitchen/
RUN if [ -n "${DOCKER_TAG}" ]; then /bin/bash -c '. /root/kitchen/tools/cobbler_initialize.sh'; fi;