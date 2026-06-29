;;; init.el --- Minimal, conventional, Rust-focused config -*- lexical-binding: t; -*-

;;; ─── Package management: straight.el + use-package ─────────────────────────
;; package.el is disabled in early-init.el (package-enable-at-startup nil),
;; which is exactly what straight.el wants. Bootstrap straight:
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package via straight and make :straight t the default, so a bare
;; `use-package` form clones the package. Built-ins opt out with :straight nil.
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;;; ─── Sane defaults ────────────────────────────────────────────────────────
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      ring-bell-function 'ignore
      use-short-answers t              ; y/n instead of yes/no
      sentence-end-double-space nil)

(setq-default indent-tabs-mode nil     ; spaces, not tabs
              tab-width 4
              fill-column 100)

;; Reset GC after startup (early-init.el cranked it to the moon).
(setq gc-cons-threshold (* 32 1024 1024))

;; Called from Lisp with no arg, a minor mode ENABLES — so the `1` is optional.
(global-display-line-numbers-mode)
(column-number-mode)
(electric-pair-mode)                    ; auto-close brackets / quotes
(delete-selection-mode)                 ; typing replaces the active region
(savehist-mode)                         ; persist minibuffer history
(recentf-mode)                          ; remember recent files
(global-auto-revert-mode)               ; reload files changed on disk
(setq global-auto-revert-non-file-buffers t)

;; which-key is bundled since Emacs 30.
(which-key-mode)

;; Keep Customize's auto-writes out of this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;;; ─── Theme + font ─────────────────────────────────────────────────────────
(load-theme 'modus-vivendi t)

(let ((font "Maple Mono NF"))
  (when (member font (font-family-list))
    (set-face-attribute 'default nil :family font :height 140)))

;;; ─── macOS integration ────────────────────────────────────────────────────
;; GUI Emacs on macOS does NOT inherit your shell PATH. Without this, eglot
;; can't find rust-analyzer/cargo/psql. (emacs-mac users: swap ns-* for mac-*.)
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

(when (eq system-type 'darwin)
  (setq ns-command-modifier 'super        ; Cmd  -> Super
        ns-option-modifier 'meta          ; Opt  -> Meta
        ns-right-option-modifier 'none))   ; right Opt types accented chars

;;; ─── Minibuffer completion (the "Vertico stack") ──────────────────────────
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-s"   . consult-line)         ; incremental search in buffer
         ("C-x b" . consult-buffer)       ; buffer switch with preview
         ("M-g g" . consult-goto-line)
         ("M-g f" . consult-flymake)      ; jump between LSP diagnostics
         ("M-s r" . consult-ripgrep)      ; project-wide grep (needs `rg`)
         ("M-s f" . consult-find)))

;;; ─── In-buffer completion (built-in, Emacs 30+) ───────────────────────────
;; Inline preview as you type, fed by eglot's completion-at-point.
;; C-M-i opens the full completion menu on demand.
(add-hook 'prog-mode-hook #'completion-preview-mode)
(setq completion-auto-help 'visible
      completion-auto-select 'second-tab)

;;; ─── Tree-sitter grammars ─────────────────────────────────────────────────
;; Auto-installs grammars and remaps foo-mode -> foo-ts-mode where one exists.
(use-package treesit-auto
  :custom (treesit-auto-install 'prompt)
  :config (global-treesit-auto-mode))

;;; ─── LSP via Eglot (built-in) ─────────────────────────────────────────────
;; Bindings live under C-c e so they don't clobber Org's C-c a / c / l.
(use-package eglot
  :straight nil                         ; built-in; don't let straight clone it
  :hook ((rust-ts-mode . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c e r" . eglot-rename)
              ("C-c e a" . eglot-code-actions)
              ("C-c e f" . eglot-format-buffer))
  :custom
  (eglot-autoshutdown t)
  :config
  ;; Axum / Askama / SQLx all lean hard on proc-macros and build scripts.
  (setq-default eglot-workspace-configuration
                '(:rust-analyzer
                  (:check     (:command "clippy")
                   :procMacro (:enable t)
                   :cargo     (:buildScripts (:enable t)
                               :features "all")))))

;;; ─── Rust ─────────────────────────────────────────────────────────────────
(use-package rust-ts-mode
  :straight nil                         ; built-in
  :mode "\\.rs\\'"
  :custom (rust-ts-mode-indent-offset 4))

;; Format-on-save with rustfmt: async, point-stable. Maps rust-ts-mode already.
(use-package apheleia
  :config (apheleia-global-mode))

;;; ─── HTML templates (Askama / Datastar) ──────────────────────────────────
;; Askama is Jinja-ish ({{ }} / {% %}); Datastar adds plain data-* attributes.
(use-package web-mode
  :mode (("\\.html\\'" . web-mode)
         ("\\.j2\\'"   . web-mode))
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-engines-alist '(("django" . "\\.html\\'"))))

;;; ─── SQL (SQLx migrations, psql) ──────────────────────────────────────────
(use-package sql
  :straight nil                         ; built-in
  :custom (sql-postgres-login-params '(user password server database port)))

;;; ─── Git ──────────────────────────────────────────────────────────────────
(use-package magit
  :bind ("C-x g" . magit-status))

;;; ─── Markdown (docs / READMEs) ────────────────────────────────────────────
(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

;;; ─── Org ──────────────────────────────────────────────────────────────────
;; :type built-in keeps Emacs' bundled org AND registers it, so when org-roam
;; pulls org as a dependency, straight won't clone a second copy.
(use-package org
  :straight (org :type built-in)
  :custom
  (org-directory "~/org")
  (org-agenda-files (list org-directory))
  (org-startup-indented t)             ; clean outline indentation
  (org-hide-emphasis-markers t)        ; show *bold* not the markers
  (org-return-follows-link t)
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link)))

;; org-roam uses Emacs 29+'s built-in SQLite, so no external binary needed.
;; Create ~/org/roam yourself before first use.
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n l" . org-roam-buffer-toggle))
  :config
  (org-roam-db-autosync-mode))

;;; ─── Load Customize file last, if it exists ───────────────────────────────
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
