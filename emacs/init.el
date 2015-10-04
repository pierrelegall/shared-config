;;;;
;;;; Emacs configuration file
;;;;

;;;; Global window

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;;; Navigation

(setq scroll-margin 2)
(setq scroll-step 2)
(setq mouse-wheel-follow-mouse (quote t))
(setq mouse-wheel-mode t)
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-scroll-amount (quote (2 ((shift) . 1))))

;;;; Behavior

(setq inhibit-startup-screen t)
(setq-default indent-tabs-mode nil)
(setq default-tab-width 2)
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default message-log-max nil)
(delete-selection-mode 1)
(show-paren-mode 1)
(global-visual-line-mode 1)

;;;; Bottom buffer

(setq line-number-mode 1)
(setq column-number-mode 1)
(setq read-file-name-completion-ignore-case t)

;;;; Keymap

(defvar my-global-keymap (make-keymap) "my global keymap")
(define-minor-mode my-global-keymap-mode "my global keymap" :keymap my-global-keymap)
(setq-default my-global-keymap-mode 1)

(define-key my-global-keymap (kbd "C-w") 'kill-region-or-backward-word)
(define-key my-global-keymap (kbd "C-S-w") 'kill-ring-save)
(define-key my-global-keymap (kbd "C-S-y") 'yank-pop)
(define-key my-global-keymap (kbd "C-x C-k") 'kill-this-buffer)
(define-key my-global-keymap (kbd "C-%") 'query-replace)

(define-key my-global-keymap (kbd "C-j") 'keyboard-escape-quit)

(define-key my-global-keymap (kbd "C-h") 'backward-delete-char-untabify)
(define-key my-global-keymap (kbd "C-S-h") 'backward-kill-word)
(define-key my-global-keymap (kbd "C-S-d") 'kill-word)

(define-key my-global-keymap (kbd "C-!") 'bash-mode)
(define-key my-global-keymap (kbd "C-`") 'rename-buffer)

(define-key my-global-keymap (kbd "C-,") 'backward-word)
(define-key my-global-keymap (kbd "C-.") 'forward-word)
(define-key my-global-keymap (kbd "C-<") 'beginning-of-buffer)
(define-key my-global-keymap (kbd "C->") 'end-of-buffer)

(define-key my-global-keymap (kbd "<C-tab>") 'next-buffer)
(define-key my-global-keymap (kbd "<C-iso-lefttab>") 'previous-buffer)

(define-key my-global-keymap (kbd "C-S-l") 'goto-line)

(define-key my-global-keymap (kbd "C-;") 'comment-or-uncomment-region)

;;(define-key my-global-keymap (kbd "C-/") 'toggle-letter-case)

(define-key my-global-keymap (kbd "C-o")
  (lambda() (interactive) (other-window 1)))
(define-key my-global-keymap (kbd "C-S-o")
  (lambda() (interactive) (other-window -1)))
(define-key my-global-keymap (kbd "C-x o")
  (lambda() (interactive) (other-window 1)))
(define-key my-global-keymap (kbd "C-x O")
  (lambda() (interactive) (other-window -1)))

(define-key my-global-keymap (kbd "C-+") 'text-scale-increase)
(define-key my-global-keymap (kbd "C--") 'text-scale-decrease)

(define-key my-global-keymap (kbd "<C-return>") 'newline-down)
(define-key my-global-keymap (kbd "C-S-<return>") 'newline-up)
(define-key my-global-keymap (kbd "<M-down>") 'move-line-down)
(define-key my-global-keymap (kbd "<M-up>") 'move-line-up)

(define-key my-global-keymap (kbd "C-c a") 'org-agenda)
(define-key my-global-keymap (kbd "C-c l") 'org-store-link)

(define-key my-global-keymap [C-f1] 'show-absolute-buffer-file-path)

;;;; Clipboard

(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;;;; Formating style

(setq c-default-style "linux")
(setq c-basic-offset 2)
(setq js-indent-level 2)

;;;; Files and backups

(setq auto-save-default nil)
(setq backup-inhibited t)
(setq make-backup-files nil)

;;;; Org

(setq org-todo-keywords '((sequence "TODO" "IN PROGRESS" "WAITING" "|" "DONE")))

;;;; Ido

(require 'ido)
(ido-mode t)
;;(ido-mode 'buffers) ;; only use this line to turn off ido for file names!
(setq ido-ignore-buffers '("^ " "*Completions*" "*Shell Command Output*"
                           "*Messages*" "Async Shell Command"))

;;;; Packages

(setq package-archives '(
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa"     . "http://melpa.milkbox.net/packages/")
                         ))

;;;; Theme and faces

(load-theme 'deeper-blue t)

;;;; Server mode

(load "server")
(unless (server-running-p) (server-start))

;;;; Functions

(defun semnav-up (arg)
  (interactive "p")
  (when (nth 3 (syntax-ppss))
    (if (> arg 0)
        (progn
          (skip-syntax-forward "^\"")
          (goto-char (1+ (point)))
          (decf arg))
      (skip-syntax-backward "^\"")
      (goto-char (1- (point)))
      (incf arg)))
  (up-list arg))

(defun select-by-step (arg &optional incremental)
  "Select the current word.
Subsequent calls expands the selection to larger semantic unit."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (or (and transient-mark-mode mark-active)
                         (eq last-command this-command))))
  (if incremental
      (progn
        (semnav-up (- arg))
        (forward-sexp)
        (mark-sexp -1))
    (if (> arg 1)
        (extend-selection (1- arg) t)
      (if (looking-at "\\=\\(\\s_\\|\\sw\\)*\\_>")
          (goto-char (match-end 0))
        (unless (memq (char-before) '(?\) ?\"))
          (forward-sexp)))
      (mark-sexp -1))))

(defun select-text-in-quote ()
  "Select text between the nearest left and right delimiters.
Delimiters are paired characters: ()[]<>«»“”‘’「」, including \"\"."
  (interactive)
  (let (b1 b2)
    (skip-chars-backward "^\"'([<")
    (setq b1 (point))
    (skip-chars-forward "^\"')[>")
    (setq b2 (point))
    (set-mark b1)))

(defun select-current-word ()
  "Select the current line"
  (interactive)
  (beginning-of-line)
  (cua-set-mark)
  (forward-word))

(defun select-current-line ()
  "Select the current line"
  (interactive)
  (beginning-of-line)
  (cua-set-mark)
  (end-of-line))

(defun select-current-paragraph ()
  "Select the current line"
  (interactive)
  (backward-paragraph)
  (next-line)
  (cua-set-mark)
  (forward-paragraph))

(defun toggle-letter-case ()
  "Toggle the letter case of current word or text selection.
Toggles between: “all lower”, “Init Caps”, “ALL CAPS”."
  (interactive)
  (let (p1 p2 (deactivate-mark nil) (case-fold-search nil))
    (if (use-region-p)
        (setq p1 (region-beginning) p2 (region-end))
      (let ((bds (bounds-of-thing-at-point 'word)))
        (setq p1 (car bds) p2 (cdr bds))))
    (when (not (eq last-command this-command))
      (save-excursion
        (goto-char p1)
        (cond
         ((looking-at "[[:lower:]][[:lower:]]") (put this-command 'state "all lower"))
         ((looking-at "[[:upper:]][[:upper:]]") (put this-command 'state "all caps"))
         ((looking-at "[[:upper:]][[:lower:]]") (put this-command 'state "init caps"))
         ((looking-at "[[:lower:]]") (put this-command 'state "all lower"))
         ((looking-at "[[:upper:]]") (put this-command 'state "all caps"))
         (t (put this-command 'state "all lower")))))
    (cond
     ((string= "all lower" (get this-command 'state))
      (upcase-initials-region p1 p2) (put this-command 'state "init caps"))
     ((string= "init caps" (get this-command 'state))
      (upcase-region p1 p2) (put this-command 'state "all caps"))
     ((string= "all caps" (get this-command 'state))
      (downcase-region p1 p2) (put this-command 'state "all lower")))))

(defun newline-up ()
  (interactive)
  (beginning-of-line)
  (newline)
  (previous-line))

(defun newline-down ()
  (interactive)
  (end-of-line)
  (newline))

(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(defun show-absolute-buffer-file-path ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(defun kill-region-or-backward-word ()
  "If the region is active and non-empty, call `kilregion'.
Otherwise, call `backward-kill-word'."
  (interactive)
  (call-interactively
   (if (use-region-p) 'kill-region 'backward-kill-word)))

(defun bash-mode ()
  "Run an ansi-term with bash in the current buffer."
  (interactive)
  (ansi-term "/bin/bash" nil))

;;;; Hooks

(add-hook 'emacs-startup-hook
          (lambda ()
            (kill-buffer "*Messages*")))

(add-hook 'minibuffer-exit-hook
          '(lambda ()
             (let ((buffer "*Completions*"))
               (and (get-buffer buffer)
                    (kill-buffer buffer)))))
