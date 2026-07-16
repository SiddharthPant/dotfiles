.PHONY: all help install clean macos arch wsl common

DOTFILES_DIR := $(CURDIR)
UNAME_S := $(shell uname)
PLATFORM := arch

ifeq ($(UNAME_S),Darwin)
PLATFORM := macos
else ifneq ($(WSL_DISTRO_NAME),)
PLATFORM := wsl
endif

define ensure_link
	@src="$(1)"; dst="$(2)"; \
	mkdir -p "$$(dirname "$$dst")"; \
	if [ -L "$$dst" ] && [ "$$(readlink "$$dst")" = "$$src" ]; then \
		printf 'ok %s\n' "$$dst"; \
	elif [ -L "$$dst" ]; then \
		rm "$$dst"; \
		ln -s "$$src" "$$dst"; \
		printf 'relinked %s -> %s\n' "$$dst" "$$src"; \
	elif [ -e "$$dst" ]; then \
		printf 'error: %s exists and is not a symlink\n' "$$dst" >&2; \
		exit 1; \
	else \
		ln -s "$$src" "$$dst"; \
		printf 'linked %s -> %s\n' "$$dst" "$$src"; \
	fi
endef

define remove_managed_link
	@src="$(1)"; dst="$(2)"; \
	if [ -L "$$dst" ] && [ "$$(readlink "$$dst")" = "$$src" ]; then \
		rm "$$dst"; \
		printf 'removed %s\n' "$$dst"; \
	else \
		printf 'skip %s\n' "$$dst"; \
	fi
endef

# target: all - Default target, runs install
all: install

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: install - Auto-detect OS and setup dotfiles
install: $(PLATFORM)

# target: macos - Setup symlinks for macOS
macos: common
	$(call ensure_link,$(DOTFILES_DIR)/zshrc/macos/.zshrc,$(HOME)/.zshrc)
	$(call ensure_link,$(DOTFILES_DIR)/.config/fish/macos/config.fish,$(HOME)/.config/fish/config.fish)
	$(call ensure_link,$(DOTFILES_DIR)/.config/fish/macos/fish_plugins,$(HOME)/.config/fish/fish_plugins)
	$(call ensure_link,$(DOTFILES_DIR)/.config/mise/macos/config.toml,$(HOME)/.config/mise/config.toml)
	@echo "macOS dotfiles linked"

# target: arch - Setup symlinks for Arch Linux
arch: common
	$(call ensure_link,$(DOTFILES_DIR)/zshrc/arch-i3/.zshrc,$(HOME)/.zshrc)
	@echo "Arch Linux dotfiles linked"

# target: wsl - Setup symlinks for WSL
wsl: common
	$(call ensure_link,$(DOTFILES_DIR)/.config/fish/wsl/config.fish,$(HOME)/.config/fish/config.fish)
	$(call ensure_link,$(DOTFILES_DIR)/.config/mise/wsl/config.toml,$(HOME)/.config/mise/config.toml)
	@echo "WSL dotfiles linked"

# Common symlinks for all platforms
common:
	$(call ensure_link,$(DOTFILES_DIR)/.gitconfig,$(HOME)/.gitconfig)
	$(call ensure_link,$(DOTFILES_DIR)/.tmux.conf,$(HOME)/.tmux.conf)
	$(call ensure_link,$(DOTFILES_DIR)/.zshenv,$(HOME)/.zshenv)
	$(call ensure_link,$(DOTFILES_DIR)/.config/nvim,$(HOME)/.config/nvim)
	$(call ensure_link,$(DOTFILES_DIR)/.config/herdr/config.toml,$(HOME)/.config/herdr/config.toml)
	mkdir -p $(HOME)/.config/herdr/plugins/config/
	$(call ensure_link,$(DOTFILES_DIR)/.config/herdr/plugins/config/cloudmanic.herdr-plus,$(HOME)/.config/herdr/plugins/config/cloudmanic.herdr-plus)
	$(call ensure_link,$(DOTFILES_DIR)/.config/ghostty,$(HOME)/.config/ghostty)
	$(call ensure_link,$(DOTFILES_DIR)/.config/kitty,$(HOME)/.config/kitty)
	$(call ensure_link,$(DOTFILES_DIR)/.config/zed,$(HOME)/.config/zed)
	$(call ensure_link,$(DOTFILES_DIR)/.config/emacs,$(HOME)/.config/emacs)
	$(call ensure_link,$(DOTFILES_DIR)/.config/starship.toml,$(HOME)/.config/starship.toml)
	$(call ensure_link,$(DOTFILES_DIR)/.config/gh/config.yml,$(HOME)/.config/gh/config.yml)
	$(call ensure_link,$(DOTFILES_DIR)/.config/jj/config.toml,$(HOME)/.config/jj/config.toml)
	$(call ensure_link,$(DOTFILES_DIR)/.config/sqlfluff,$(HOME)/.config/sqlfluff)
	$(call ensure_link,$(DOTFILES_DIR)/.pi/agent/settings.json,$(HOME)/.pi/agent/settings.json)
	$(call ensure_link,$(DOTFILES_DIR)/.pi/agent/themes,$(HOME)/.pi/agent/themes)
	$(call ensure_link,$(DOTFILES_DIR)/.pi/web-search.json,$(HOME)/.pi/web-search.json)
	@echo "Common dotfiles linked"

# target: clean - Remove all dotfile symlinks
clean:
	$(call remove_managed_link,$(DOTFILES_DIR)/zshrc/macos/.zshrc,$(HOME)/.zshrc)
	$(call remove_managed_link,$(DOTFILES_DIR)/zshrc/arch-i3/.zshrc,$(HOME)/.zshrc)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/fish/macos/config.fish,$(HOME)/.config/fish/config.fish)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/fish/macos/fish_plugins,$(HOME)/.config/fish/fish_plugins)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/fish/wsl/config.fish,$(HOME)/.config/fish/config.fish)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/mise/macos/config.toml,$(HOME)/.config/mise/config.toml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/mise/wsl/config.toml,$(HOME)/.config/mise/config.toml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.gitconfig,$(HOME)/.gitconfig)
	$(call remove_managed_link,$(DOTFILES_DIR)/.tmux.conf,$(HOME)/.tmux.conf)
	$(call remove_managed_link,$(DOTFILES_DIR)/.zshenv,$(HOME)/.zshenv)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/nvim,$(HOME)/.config/nvim)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/herdr/config.toml,$(HOME)/.config/herdr/config.toml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/herdr/plugins/config/cloudmanic.herdr-plus,$(HOME)/.config/herdr/plugins/config/cloudmanic.herdr-plus)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/ghostty,$(HOME)/.config/ghostty)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/kitty,$(HOME)/.config/kitty)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/zed,$(HOME)/.config/zed)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/emacs,$(HOME)/.config/emacs)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/starship.toml,$(HOME)/.config/starship.toml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/gh/config.yml,$(HOME)/.config/gh/config.yml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/jj/config.toml,$(HOME)/.config/jj/config.toml)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/sqlfluff,$(HOME)/.config/sqlfluff)
	$(call remove_managed_link,$(DOTFILES_DIR)/.pi/agent/settings.json,$(HOME)/.pi/agent/settings.json)
	$(call remove_managed_link,$(DOTFILES_DIR)/.pi/agent/themes,$(HOME)/.pi/agent/themes)
	$(call remove_managed_link,$(DOTFILES_DIR)/.pi/web-search.json,$(HOME)/.pi/web-search.json)
	@echo "Dotfiles unlinked"
