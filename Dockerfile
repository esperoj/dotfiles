FROM kalilinux/kali-rolling
ARG PACKAGES="BASE NET CI"
ARG MACHINE_NAME="ci"
ENV PATH="/root/scripts:${PATH}"
WORKDIR /root/
COPY --dir scripts .
RUN setup.sh install \
      && apt-get autoremove -qqy
COPY dotfiles .local/share/chezmoi
RUN ls -al .local/share/chezmoi
