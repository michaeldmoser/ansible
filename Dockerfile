FROM ubuntu:jammy
LABEL maintainer="Michael Moser"

ARG DEBIAN_FRONTEND=noninteractive

ENV pip_packages "ansible"

RUN apt-get update && apt -y install software-properties-common

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       build-essential \
       locales \
       libffi-dev \
       libssl-dev \
       libyaml-dev \
       python3-dev \
       python3-setuptools \
       python3-pip \
       python3-yaml \
       python3-apt \
       python3-debian \
       python3-venv \
       software-properties-common \
       rsyslog systemd systemd-cron sudo iproute2 \
       neovim \
       openssh-client \
       git \
       i3-wm \
    && apt-get install -y xauth libxcb-render0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xtest0-dev \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man

RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -ms /bin/bash ubuntu
USER ubuntu
RUN python3 -m pip install pipx
RUN python3 -m pipx install --include-deps ansible
RUN echo "export PATH=\$PATH:/home/ubuntu/.local/bin" >> /home/ubuntu/.bashrc

COPY ./requirements.yml /tmp/requirements.yml
RUN /home/ubuntu/.local/bin/ansible-galaxy install -r /tmp/requirements.yml

