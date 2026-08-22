;;; early-init.el --- Runs before the GUI frame is created -*- lexical-binding: t; -*-

;; Defer garbage collection during startup; init.el restores it.
(setq gc-cons-threshold most-positive-fixnum)

(setq select-enable-clipboard t)

(setq inhibit-startup-message t
      frame-resize-pixelwise t
      initial-frame-alist '((fullscreen . maximized))
      default-frame-alist '((tool-bar-lines . 0)
                            (menu-bar-lines . 0)
                            (vertical-scroll-bars . nil)
                            (ns-transparent-titlebar . t)
                            (fullscreen . maximized)))
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
