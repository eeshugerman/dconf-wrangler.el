;;; dconf-dotfile.el --- Plain text dconf management tool  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  elliott

;; Author: elliott<eeshugerman@gmail.com>
;; Version: 0.0.1
;; Keywords: convenience, data, tools, maint

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:


(defgroup dconf-dotfile nil
  "Plain text dconf management tool")

(defcustom dconf-dotfile-dump-base-schema "/"
  "Base dconf schema to operate on"
  :type 'string
  :group 'dconf-dotfile)

(defcustom dconf-dotfile-dconf-config-file-path (f-join (or (getenv "XDG_CONFIG_HOME")
                                                             (expand-file-name "~/.config"))
                                                         "dconf-user.conf")
  "Path to dconf config file to operate on")

(defvar dconf-dotfile--frame nil)
(defvar dconf-dotfile--source-buffer nil)
(defvar dconf-dotfile--target-buffer nil)

(define-derived-mode dconf-dotfile-dump-mode special-mode "dconf dump"
  "Mode for browsing output of `dconf dump`"
  :group 'dconf-dotfile
  ;; doesn't seem to matter for syntax highlighting but maybe does for other stuff?
  :syntax-table conf-toml-mode-syntax-table
  ;; use conf-toml-mode's syntax highlighting
  (conf-mode-initialize "#" 'conf-toml-font-lock-keywords)
  (read-only-mode +1))

(defun dconf-dotfile--init (source-type)
  (let* ((frame (make-frame))
         (target-window (frame-root-window frame))
         (source-window (split-window target-window nil 'right))
         (target-buffer (find-file dconf-dotfile-dconf-config-file-path))
         (source-buffer (get-buffer-create (format "*dconf-dotfile-%s*" source-type))))

    (setq dconf-dotfile--frame frame)
    (setq dconf-dotfile--source-buffer source-buffer)
    (setq dconf-dotfile--target-buffer target-buffer)

    (set-window-buffer target-window target-buffer)
    (set-window-buffer source-window source-buffer)

    (with-current-buffer target-buffer (conf-toml-mode))))

(defun dconf-dotfile-dump ()
  "dconf dump"
  (interactive)
  (dconf-dotfile--init "dump")
  (let ((command (format "dconf dump %s" dconf-dotfile-dump-base-schema))
        (source-buffer dconf-dotfile--source-buffer))
    (shell-command command source-buffer "*Messages*")
    (with-current-buffer source-buffer (dconf-dotfile-dump-mode))))


(defun dconf-dotfile-quit ()
  (interactive)
  ;; todo: prompt to save if there are changes
  (kill-buffer dconf-dotfile--target-buffer)
  (kill-buffer dconf-dotfile--source-buffer)
  (delete-frame dconf-dotfile--frame))

(provide 'dconf-dotfile)

;;; dconf-dotfile.el ends here