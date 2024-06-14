FROM archlinux/archlinux:base-devel as update-mirrors
    MAINTAINER Eliseu Lucena Barros <eliseu42lucena@gmail.com>
# Arch Linux base docker container with AUR helper (paru or yay, default paru)

# update mirrorlist
ADD https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh /usr/bin/get-new-mirrors
RUN chmod +x /usr/bin/get-new-mirrors
RUN get-new-mirrors

from update-mirrors as build-helper-img
# probably is ab
ARG AUR_USER

# can be paru or yay
ARG HELPER

# install helper and add a user for it
ADD add-aur.sh /root
RUN bash /root/add-aur.sh "${AUR_USER}" "${HELPER}"

# now to install from the AUR, you might do something like this in your Dockerfile:
# RUN aur-install aur-package1 aur-package2 non-aur-package3

RUN pacman -S --noconfirm sudo

RUN groupadd sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN useradd -m -s /bin/bash -g root -G wheel -G sudo app

RUN pacman -S --noconfirm cmake
RUN pacman -S --noconfirm luajit boost-libs fmt openssl ncurses serd sord liburing libcap
RUN pacman -S --noconfirm git meson boost cereal re2c gawk gperf asciidoctor

USER app
WORKDIR /home/app

RUN yay -S --noconfirm emilua
