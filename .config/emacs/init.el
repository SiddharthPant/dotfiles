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
  (load-theme 'doom-meltbus t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package rainbow-delimiters
  :ensure t
  :hook ((prog-mode . rainbow-delimiters-mode)
         (conf-mode . rainbow-delimiters-mode))
  :config
  (dolist (face-color '((rainbow-delimiters-depth-1-face unspecified)
                        (rainbow-delimiters-depth-2-face "#a9a1e1")
                        (rainbow-delimiters-depth-3-face "#7cab7c")
                        (rainbow-delimiters-depth-4-face "#cdad00")
                        (rainbow-delimiters-depth-5-face "#db7093")
                        (rainbow-delimiters-depth-6-face "#87afff")
                        (rainbow-delimiters-depth-7-face "#a9a1e1")
                        (rainbow-delimiters-depth-8-face "#7cab7c")
                        (rainbow-delimiters-depth-9-face "#cdad00")))
    (set-face-attribute (car face-color) nil
                        :inherit 'rainbow-delimiters-base-face
                        :foreground (cadr face-color))))

(set-face-attribute 'default nil
                    :family "Iosevka Term"
                    :height 160)
;; After loading theme and font make frame visible again
(set-frame-parameter nil 'visibility t)

(setq make-backup-files nil
      auto-save-default nil
      desktop-restore-frames nil
      pixel-scroll-precision-interpolate-page t
      ring-bell-function 'ignore
      undo-limit (* 20 1024 1024)
      undo-strong-limit (* 40 1024 1024))
(setq-default indent-tabs-mode nil
              cursor-type '(bar . 2)
              tab-width 4)

(blink-cursor-mode -1)
(column-number-mode 1)
(show-paren-mode 1)
(fido-vertical-mode 1)
(repeat-mode 1)
(winner-mode 1)
(savehist-mode 1)
(desktop-save-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(pixel-scroll-precision-mode 1)

(add-to-list 'auto-mode-alist '("/\\.env\\(?:\\..*\\)?\\'" . conf-unix-mode))
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
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
(add-hook 'before-save-hook 'whitespace-cleanup)

(use-package multiple-cursors
  :ensure t
  :custom (mc/always-run-for-all t)
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-\"" . mc/skip-to-next-like-this)
         ("C-|" . mc/skip-to-previous-like-this)
         ("C-S-<mouse-1>" . mc/toggle-cursor-on-click)))
(use-package expand-region
  :bind ("C-=" . er/expand-region))
(use-package avy
  :ensure t
  :bind (("C-;" . avy-goto-char-2)
         ("M-g g" . avy-goto-line)))
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))
(use-package rust-mode :ensure t)
(use-package magit :ensure t)
(use-package vc-jj :ensure t)

;; Restore garbage collection after startup.
(setq gc-cons-threshold (* 32 1024 1024))

;;; init.el ends here
(put 'downcase-region 'disabled nil)
