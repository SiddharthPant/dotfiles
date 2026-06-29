;;; early-init.el --- Runs before the GUI frame is created -*- lexical-binding: t; -*-

;; Crank the GC threshold during startup; init.el resets it to a sane value.
(setq gc-cons-threshold most-positive-fixnum)

;; We initialize package.el ourselves in init.el, so don't do it twice.
(setq package-enable-at-startup nil)

;; Kill the UI chrome before the first frame paints (avoids a visible flash).
(setq inhibit-startup-message t
      frame-resize-pixelwise t
      default-frame-alist '((tool-bar-lines . 0)
                            (menu-bar-lines . 0)
                            (vertical-scroll-bars . nil)
                            (ns-transparent-titlebar . t)))
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Native-comp is great but noisy on first compile; keep warnings quiet.
(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends heres
