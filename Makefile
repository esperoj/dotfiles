.ONESHELL:
.DELETE_ON_ERROR:
.SHELLFLAGS     := -eu -o pipefail -c
MAKEFLAGS       += --warn-undefined-variables
MAKEFLAGS       += --no-builtin-rules
SHELL           := bash
export

DEBIAN_FRONTEND := noninteractive
LOCAL_BIN       := $(HOME)/.local/bin
PATH            := $(LOCAL_BIN):$(HOME)/bin:$(PATH)
SETUP_NAME      ?= docker_base


docker_base: $(HOME)/ports/
	$(MAKE) -j1 dotfiles docker_base_ports
docker_base_ports:
	apt-get install -qqy --no-install-recommends \
	    jq \
	    time \
	    tmux
	$(MAKE) -j -C "${HOME}/ports" 7zip caddy pipx rclone esperoj
.PHONY: docker_base docker_base_ports

docker_main: docker_main_pkgs docker_main_ports
docker_main_pkgs:
	apt-get install -qqy --no-install-recommends \
	    ffmpeg \
	    rename
docker_main_ports:
	$(MAKE) -C "${HOME}/ports" exiftool yt_dlp
.PHONY: docker_main docker_main_pkgs docker_main_ports

docker_dev: docker_dev_pkgs docker_dev_ports
docker_dev_pkgs:
	apt-get install -qqy --no-install-recommends \
	    nodejs \
	    npm \
	    vim \
	    zsh
	$(MAKE) -C "${HOME}/ports" oh_my_zsh
docker_dev_ports:
	$(MAKE) -C "${HOME}/ports" fzf shfmt
.PHONY: docker_dev docker_dev_pkgs docker_dev_ports

termux:
	apt-get install -qqy --no-install-recommends \
	    aria2 \
	    exiftool \
	    gnupg \
	    git \
	    inetutils \
	    jq \
	    openssh \
	    p7zip \
	    parallel \
	    rclone \
	    time \
	    tmux \
	    unzip \
	    vim \
	    wget \
	    xz-utils \
	    zsh
	$(MAKE) -C "${HOME}/ports" fzf oh_my_zsh
.PHONY: termux

$(HOME)/ports/:
	cd "${HOME}"
	git clone --depth=1 https://codeberg.org/esperoj/ports.git
	(
	  cd ports
	  git remote set-url origin git@codeberg.org/esperoj/ports.git
	)

clean:
	@case "$${SETUP_NAME}" in
	@docker_*)
	    rm -rf ~/.cache/ /var/lib/apt/lists/ /var/cache/ /usr/share/{doc,man}
	    mkdir -p /var/cache/apt/archives/partial
	    rm Makefile
	@;;
	@esac
.PHONY: clean

dotfiles: $(HOME)/.local/share/chezmoi
.PHONY: dotfiles

$(HOME)/.local/share/chezmoi:
	$(MAKE) -C "${HOME}/ports" dotfiles
