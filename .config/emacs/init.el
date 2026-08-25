;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

;; Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Appearance
(setq custom-safe-themes t)

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  (load-theme 'doom-dracula t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))
(set-face-attribute 'default nil
		    :family "Iosevka Term"
		    :height 150)
;; After loading theme and font make frame visible again
(set-frame-parameter nil 'visibility t)

(setq make-backup-files nil
      auto-save-default nil
      desktop-restore-frames nil
      ;; display-line-numbers-type 'relative
      ring-bell-function 'ignore
      undo-limit (* 20 1024 1024)
      undo-strong-limit (* 40 1024 1024))
(setq-default indent-tabs-mode nil
              tab-width 4)

(column-number-mode 1)
(show-paren-mode 1)
(fido-vertical-mode 1)
(repeat-mode 1)
(winner-mode 1)
(savehist-mode 1)
(desktop-save-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(keymap-global-set "C-c d" #'duplicate-dwim)
(keymap-global-set "C-x C-b" #'ibuffer)
(keymap-global-set "<f5>" #'recompile)

(setq delete-by-moving-to-trash t
      dired-dwim-target t
      dired-listing-switches "-alh"
      dired-mouse-drag-files t)

(require 'ansi-color)
(setq compilation-scroll-output 'first-error
      compilation-always-kill t)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-\"" . mc/skip-to-next-like-this)
         ("C-:" . mc/skip-to-previous-like-this)
         ("C-S-<mouse-1>" . mc/toggle-cursor-on-click)))

(use-package rust-mode :ensure t)
(use-package magit :ensure t)
(use-package vc-jj :ensure t)

;; Restore garbage collection after startup.
(setq gc-cons-threshold (* 32 1024 1024))

;;; init.el ends here
