;; * Company mode

(my/ensure-package-installed 'company)

(require 'company)

(setq company-tooltip-align-annotations t)

(add-hook 'after-init-hook 'global-company-mode)

(define-key company-mode-map (kbd "C-S-i") #'company-complete)
(define-key company-active-map (kbd "C-n") #'company-select-next)
(define-key company-active-map (kbd "C-p") #'company-select-previous)
(define-key company-active-map (kbd "C-?") #'company-show-doc-buffer)
