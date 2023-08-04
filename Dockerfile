FROM kalilinux/kali-rolling
ARG PACKAGES="BASE NET CI"
ARG MACHINE_NAME="ci"
ENV PATH="/root/.local/share/chezmoi/scripts:${PATH}"
WORKDIR /root/
COPY dotfiles /root/.local/share/chezmoi
RUN echo $PATH && command -v setup.sh
RUN setup.sh install \
      && apt-get autoremove -qqy
RUN ls -al .local/share/chezmoi
