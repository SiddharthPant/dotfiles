;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

;; Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Appearance
(use-package nord-theme
  :ensure t
  :config
  (load-theme 'nord t))
(set-face-attribute 'default nil
		    :family "Iosevka Term"
		    :height 140)

;; Editing
(setq confirm-kill-emacs #'y-or-n-p
      display-line-numbers-type 'relative
      make-backup-files nil
      undo-limit (* 20 1024 1024)
      undo-strong-limit (* 40 1024 1024))
(setq-default indent-tabs-mode nil
              tab-width 4)

(column-number-mode 1)
(show-paren-mode 1)
(fido-vertical-mode 1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(keymap-global-set "C-," #'duplicate-dwim)

;; File management
(setq delete-by-moving-to-trash t
      dired-dwim-target t
      dired-listing-switches "-alh"
      dired-mouse-drag-files t)

;; Development
(require 'ansi-color)

(setq compilation-scroll-output 'first-error)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))
(use-package rust-mode :ensure t)
(use-package magit :ensure t)

;; Restore garbage collection after startup.
(setq gc-cons-threshold (* 32 1024 1024))

;;; init.el ends here
