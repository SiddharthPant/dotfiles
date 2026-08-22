;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

;; Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Appearance
(use-package naysayer-theme
  :ensure t
  :config
  (load-theme 'naysayer t))
(set-face-attribute 'default nil
		    :family "Iosevka Term"
		    :height 140)

;; Editing
(setq make-backup-files nil
      display-line-numbers-type 'relative)
(setq-default indent-tabs-mode nil
              tab-width 4)

(column-number-mode 1)
(show-paren-mode 1)
(fido-vertical-mode 1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Development
(use-package rust-mode :ensure t)
(use-package magit :ensure t)
(use-package majutsu
  :vc (:url "https://github.com/0WD0/majutsu")
  :commands (majutsu majutsu-log))

;; Restore garbage collection after startup.
(setq gc-cons-threshold (* 32 1024 1024))

;;; init.el ends here
