#!/usr/bin/env bash
#
docker run -it \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=host.docker.internal:0 \
    -v ./:/ansible \
    --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH \
    ansible-testing bash 
