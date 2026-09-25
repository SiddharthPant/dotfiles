;;; early-init.el --- Runs before the GUI frame is created -*- lexical-binding: t; -*-

;; Make frame invisible till we load theme and font
(add-to-list 'initial-frame-alist '(visibility . nil))

;; Defer garbage collection during startup; init.el restores it.
(setq gc-cons-threshold most-positive-fixnum)

(setq inhibit-startup-message t
      frame-resize-pixelwise t
      default-frame-alist '((tool-bar-lines . 0)
                            (menu-bar-lines . 0)
                            ;; (vertical-scroll-bars . nil)
                            (ns-transparent-titlebar . t)))
                            ;; (fullscreen . maximized)))
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq select-enable-clipboard nil)
(setq select-enable-primary nil)

(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
