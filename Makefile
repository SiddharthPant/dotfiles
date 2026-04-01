.PHONY: all help install clean macos arch

DOTFILES_DIR := $(CURDIR)

# target: all - Default target, runs install
all: install

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: install - Auto-detect OS and setup dotfiles
install:
ifeq ($(shell uname),Darwin)
	$(MAKE) macos
else
	$(MAKE) arch
endif

# target: macos - Setup symlinks for macOS
macos: common
	ln -sf $(DOTFILES_DIR)/zshrc/macos/.zshrc $(HOME)/.zshrc
	@echo "macOS dotfiles linked"

# target: arch - Setup symlinks for Arch Linux
arch: common
	ln -sf $(DOTFILES_DIR)/zshrc/arch-i3/.zshrc $(HOME)/.zshrc
	@echo "Arch Linux dotfiles linked"

# Common symlinks for all platforms
common:
	ln -sf $(DOTFILES_DIR)/.tmux.conf $(HOME)/.tmux.conf
	mkdir -p $(HOME)/.config
	ln -sf $(DOTFILES_DIR)/.config/nvim $(HOME)/.config/nvim
	@echo "Common dotfiles linked"

# target: clean - Remove all dotfile symlinks
clean:
	@rm -f $(HOME)/.zshrc
	@rm -f $(HOME)/.tmux.conf
	@rm -rf $(HOME)/.config/nvim
	@echo "Dotfiles unlinked"
