;; * Emacs configuration entry point

;; ** Package initialization

(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; ** My functions initialization

(defvar my/functions-file
  "~/.config/emacs/my-functions.el"
  "My functions file.")

(defun my/load-functions ()
  "Load my functions file."
  (load-file my/functions-file))

(my/load-functions)

;; ** My global map initialization

(defvar my/global-map-file
  "~/.config/emacs/my-global-map.el"
  "My global map file.")

(defun my/load-global-map ()
  "Load my global map file."
  (load-file my/global-map-file))

(my/load-global-map)

;; ** Init files loading

(defvar my/packages-init-files-directory
  "~/.config/emacs/packages-init"
  "Directory of the initialization files.")

(defvar my/packages-init-files
  (directory-files my/packages-init-files-directory t "^[^.]")
  "List of the initialization files.")

(defun my/load-packages-init-files ()
  "Load all the initialization files."
  (mapcar (lambda (package-init-file)
            (load-file package-init-file))
          my/packages-init-files))

(my/load-packages-init-files)
