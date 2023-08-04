FROM kalilinux/kali-rolling
ARG PACKAGES="BASE NET CI"
ARG MACHINE_NAME="ci"
ENV PATH="/root/.local/share/chezmoi/scripts:${PATH}"
WORKDIR /root/
COPY dotfiles/scripts/setup.sh dotfiles/scripts/pkg-install.sh /root/.local/share/chezmoi/scripts
RUN ls -al /root/.local/share/chezmoi && setup.sh install \
      && apt-get autoremove -qqy
COPY dotfiles /root/.local/share/chezmoi
