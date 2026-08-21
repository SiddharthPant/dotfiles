;; Reset GC after startup (early-init.el cranked it to the moon).
(setq gc-cons-threshold (* 32 1024 1024))

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

(load-theme 'modus-vivendi t)
(set-face-attribute 'default nil
			    :family "Iosevka Term"
		    :height 140)

;; Editing
(column-number-mode 1)
(show-paren-mode 1)

(setq-default indent-tabs-mode nil
              tab-width 4)

(setq display-line-numbers-type 'relative)

(defun sid/programming-setup ()
  (display-line-numbers-mode 1)
  (add-hook 'before-save-hook
            #'delete-trailing-whitespace nil t))

(add-hook 'prog-mode-hook #'sid/programming-setup)

;; Org
(setq org-directory "~/Documents/org"
      org-agenda-files (list org-directory)
      org-default-notes-file (expand-file-name "inbox.org" org-directory)
      org-capture-templates
      `(("t" "Task" entry
         (file ,org-default-notes-file)
         "* TODO %?\n  %U\n")))

(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c c" #'org-capture)

;; Rust
(require 'rust-ts-mode)
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

;; Version control
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package majutsu
  :vc (:url "https://github.com/0WD0/majutsu")
  :commands (majutsu majutsu-log))
