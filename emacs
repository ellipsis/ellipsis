;; Hide shit on startup
(setq inihibit-startup-screen t)
(setq vc-follow-symlinks t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)

;; Basic
(set-default-font "MonteCarlo")
(setq visible-cursor nil)
(setq cursor-in-non-selected-windows nil)
(fset 'yes-or-no-p 'y-or-n-p)

;; Evil
(add-to-list 'load-path "~/.emacs.d/evil")
(add-to-list 'load-path "~/.emacs.d/undo-tree")
(setq evil-move-cursor-back nil)
(setq evil-default-cursor t)

(require 'evil)
(evil-mode 1)
;; Remap org-mode meta keys for convenience
(mapcar (lambda (state)
    (evil-declare-key state org-mode-map
      (kbd "M-l") 'org-metaright
      (kbd "M-h") 'org-metaleft
      (kbd "M-k") 'org-metaup
      (kbd "M-j") 'org-metadown
      (kbd "M-L") 'org-shiftmetaright
      (kbd "M-H") 'org-shiftmetaleft
      (kbd "M-K") 'org-shiftmetaup
      (kbd "M-J") 'org-shiftmetadown))
  '(normal insert))

;; Colors
(add-to-list 'load-path "~/.emacs.d/colors")
(add-to-list 'load-path "~/.emacs.d/color-theme")

(require 'color-theme)
;(require 'color-theme-gruber-darker)
;(color-theme-gruber-darker)
(require 'color-theme-molokai)
(color-theme-molokai)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
