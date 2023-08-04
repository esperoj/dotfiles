FROM kalilinux/kali-rolling
ARG PACKAGES="BASE NET CI"
ARG MACHINE_NAME="ci"
ENV PATH="/root/.local/share/chezmoi/scripts:${PATH}"
WORKDIR /root/
COPY dotfiles/scripts/setup.sh dotfiles/scripts/pkg-install.sh /root/.local/share/chezmoi/scripts
RUN setup.sh install \
      && apt-get autoremove -qqy
COPY dotfiles .local/share/chezmoi
RUN ls -al .local/share/chezmoi
