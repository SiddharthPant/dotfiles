;; Reset GC after startup (early-init.el cranked it to the moon).
(setq gc-cons-threshold (* 32 1024 1024))
(load-theme 'modus-vivendi t)
(set-face-attribute 'default nil
		    :family "Iosevka Nerd Font Mono"
		    :height 140)
