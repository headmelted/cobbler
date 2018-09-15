FROM ubuntu:cosmic
ARG DOCKER_TAG
ENV arch=$DOCKER_TAG
COPY kitchen /kitchen/
WORKDIR /kitchen
ADD cobble.sh /
RUN /bin/bash -c '. /cobble.sh'
RUN rm /cobble.sh
