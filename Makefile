.PHONY: all help install clean macos arch common

DOTFILES_DIR := $(CURDIR)
UNAME_S := $(shell uname)
PLATFORM := arch

ifeq ($(UNAME_S),Darwin)
PLATFORM := macos
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
	@echo "macOS dotfiles linked"

# target: arch - Setup symlinks for Arch Linux
arch: common
	$(call ensure_link,$(DOTFILES_DIR)/zshrc/arch-i3/.zshrc,$(HOME)/.zshrc)
	@echo "Arch Linux dotfiles linked"

# Common symlinks for all platforms
common:
	$(call ensure_link,$(DOTFILES_DIR)/.tmux.conf,$(HOME)/.tmux.conf)
	$(call ensure_link,$(DOTFILES_DIR)/.config/nvim,$(HOME)/.config/nvim)
	$(call ensure_link,$(DOTFILES_DIR)/.config/ghostty,$(HOME)/.config/ghostty)
	$(call ensure_link,$(DOTFILES_DIR)/.config/kitty,$(HOME)/.config/kitty)
	@echo "Common dotfiles linked"

# target: clean - Remove all dotfile symlinks
clean:
	$(call remove_managed_link,$(DOTFILES_DIR)/zshrc/macos/.zshrc,$(HOME)/.zshrc)
	$(call remove_managed_link,$(DOTFILES_DIR)/zshrc/arch-i3/.zshrc,$(HOME)/.zshrc)
	$(call remove_managed_link,$(DOTFILES_DIR)/.tmux.conf,$(HOME)/.tmux.conf)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/nvim,$(HOME)/.config/nvim)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/ghostty,$(HOME)/.config/ghostty)
	$(call remove_managed_link,$(DOTFILES_DIR)/.config/kitty,$(HOME)/.config/kitty)
	@echo "Dotfiles unlinked"
