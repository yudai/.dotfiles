;;; -*- coding: shift_jis-dos; tab-width: 4; -*-
;;; what-char.el --- show character code at point
;;; $Id: what-char.el 1.0.0.1 2005/01/22 07:06:44 satomii Exp $

;; Copyright (C) 2002-2004, Satomi I.
;; (satomi atmark ring period gr period jp)

;; This file is NOT a part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 2 of the License, or any later
;; version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;;; Commentary:

;; what-char is a small utility that tells the encoded character codes at
;; point. It also provides a minor mode to display the character code on
;; the mode line.
;;
;; Main differences from `what-cursor-position' or `describe-char' are:
;;
;; - Simplified output. Only the character code information is displayed.
;; - Coding-system aware. Shows the character code(s) encoded by the
;;   buffer or specified coding-system(s). It would be helpful in
;;   identifying multi-byte characters.
;;
;; To show the character code at point on the echo area:
;;
;;   M-x what-char [RET]
;;
;; To enable the minor mode:
;;
;;  1. Modify `mode-line-format' to display `what-char-mode-line-format'
;;     (or something like that) when `what-char-mode' is non-nil.
;;     If you are not sure how to configure the mode line format, try
;;     evaluating the following expression:
;;
;;     (what-char-mode-line-format)
;;
;;     This will append the entry for `what-char-mode' to
;;     `mode-line-format'. If it does not work properly, your mode line
;;     format might be too complex and needs to be configured manually.
;;
;;  2. M-x what-char-mode [RET]
;;
;; To specify the coding-systems used by `what-char', customize the
;; variable `what-char-category-coding-system-alist'.
;;
;; To specify the coding-system used by `what-char-mode', customize the
;; variable `what-char-mode-line-coding-system'.

;;; Code:

(eval-when-compile
  (require 'cl))

(if (fboundp 'propertize)
	(defalias 'what-char-propertize 'propertize)
  (defsubst what-char-propertize (string &rest properties)
	(set-text-properties 0 (length string) properties string)
	string))

(defgroup what-char nil
  "Display character code at point on the mode line."
  :group 'modeline)

(defcustom what-char-mode-line-format
  (if (< 20 emacs-major-version)
	  '(:eval (what-char-propertize
			   (concat "[" what-char-current-string "]")
			   'local-map what-char-mode-line-keymap
			   'help-echo '(what-char what-char-current-char -1)))
	'("[" what-char-current-string "]"))
  "*Mode line format for displaying the character code at point.
See the documentation for `mode-line-format' for details."
  :type 'sexp
  :group 'what-char)
(put 'what-char-mode-line-format 'risky-local-variable t)

(defcustom what-char-mode-line-coding-system nil
  "*Coding system for encoding the character at point.
Used to format the character code displayed on the mode line.

If nil, the buffer's coding system `buffer-file-coding-system' is used."
  :type 'coding-system
  :group 'what-char)

(defcustom what-char-category-coding-system-alist
  `((?j . (shift_jis euc-jp))
	(?g . (shift_jis euc-jp))
	(t . ,(append (if (coding-system-p 'utf-8)
					  (list 'utf-8))
				  (if (coding-system-p 'utf-16-be-no-signature)
					  (list 'utf-16-be-no-signature)
					(if (coding-system-p 'utf-16be)
						(list 'utf-16be))))))
  "*Alist of character categories vs. coding systems.
Used by `what-char' to determine the character encodings.

Each element is a list:

  (CHAR-CATEGORY CODING-SYSTEM ...)

CHAR-CATEGORY is a character that represents the character category.
The value `t' means any category; i.e., it matches any character
regardless of the actual category set.

CODING-SYSTEM is a coding system (a symbol) for encoding a character
that belongs to CHAR-CATEGORY. More than one coding can be specified.

The coding selection is cumulative. For example:

  (setq what-char-category-coding-system-alist
	'((?j shift_jis) (t utf-8)))
  (what-char ?‚ )
      => \"S:82A0 u:E38182\""
  :group 'what-char
  :type '(repeat (cons (choice :tag "Category" character (const t))
					   (repeat coding-system))))

(defcustom what-char-idle-delay
  (if (boundp 'idle-update-delay) idle-update-delay 1)
  "*Delay time in seconds before updating the character information
such as `what-char-current-string'."
  :type 'number
  :group 'what-char)

(defvar what-char-idle-timer nil
  "Timer started after `what-char-idle-timer' seconds of idle time.")

(defvar what-char-mode nil
  "Non-nil means `what-char-mode' is enabled.")
(make-variable-buffer-local 'what-char-mode)

(defvar what-char-current-char 0
  "Current character at point.
Updated only when `what-char-mode' is enabled.")
(make-variable-buffer-local 'what-char-current-char)

(defvar what-char-current-string "??"
  "String representation of the current character at point encoded
according to the value of `what-char-mode-line-coding-system'.
Updated only when `what-char-mode' is enabled.")
(make-variable-buffer-local 'what-char-current-string)

(defun what-coding-char (char coding)
  (let ((str (encode-coding-string (char-to-string char) coding)))
	(mapconcat (lambda (c) (format "%02X" c)) str "")))

(defun what-char (char &optional arg)
  "Display the character code(s) of CHAR in the echo area.

If called interactively with prefix ARG, also run `describe-char' or
`describe-char-after'.
If called noninteractively with non-nil ARG, disable the message
output but simply return the result string.

The coding systems used to encode CHAR are taken from the buffer's
coding system `buffer-file-coding-system' and the variable
`what-char-category-coding-system-alist'."
  (interactive (list (or (following-char)
						 (error "No character at point"))
					 current-prefix-arg))
  (let ((category (char-category-set char))
		(eol (coding-system-eol-type buffer-file-coding-system))
		codings chars)
	(dolist (elem what-char-category-coding-system-alist)
	  (if (or (eq t (car elem))
			  (aref category (car elem)))
		  (dolist (cs (cdr elem))
			(when (coding-system-p cs)
			  (setq cs (coding-system-change-eol-conversion cs eol))
			  (or (coding-system-equal cs buffer-file-coding-system)
				  (memq cs codings)
				  (setq codings (cons cs codings)))))))
	(setq codings (cons buffer-file-coding-system
						(sort codings 'coding-system-lessp)))
	(dolist (cs codings)
	  ;; the mnemonic characters for utf-8 and utf-16 are both "u". is it
	  ;; necessary to make coding-system prefixes customizable...?
	  (setq chars (cons (concat (char-to-string (coding-system-mnemonic cs))
								":" (what-coding-char char cs))
						chars)))
	(setq chars (concat "\""
						(case char
						  (?\n (case eol
								 (1 "\\r\\n") (2 "\\r") (t "\\n")))
						  (?\t "\\t")
						  (t (char-to-string char)))
						"\" "
						(mapconcat 'identity (nreverse chars) " ")))
	(if arg
		(when (interactive-p)
		  (if (fboundp 'describe-char)
			  (describe-char (point))
			(describe-char-after))
		  (message "%s" chars))
	  (message "%s" chars))
	chars))

(defun what-char-update ()
  (when what-char-mode
	(let ((char (following-char)))
	  (unless (eq what-char-current-char char)
		(setq what-char-current-char char)
		(setq what-char-current-string
			  (what-coding-char char (or what-char-mode-line-coding-system
										 buffer-file-coding-system)))
		(force-mode-line-update)))))

(defun what-char-mode (&optional arg)
  "Toggle `what-char-mode'.

With prefix ARG, turn `what-char-mode' on if ARG is positive or off
otherwise."
  (interactive "P")
  (if what-char-idle-timer
	  (cancel-timer what-char-idle-timer))
  (setq what-char-mode
		(if arg (< 0 (prefix-numeric-value arg))
		  (not what-char-mode)))
  (setq what-char-idle-timer
		(if what-char-mode
			(run-with-idle-timer what-char-idle-delay t 'what-char-update)))
  (force-mode-line-update)
  (if (interactive-p)
	  (message "what-char-mode is %s" (if what-char-mode "on" "off"))))

(defun what-char-mouse-show (event)
  "Show the current character codes in response to a mouse event.
See also `what-char'."
  (interactive "@e")
  (or what-char-current-char
	  (what-char-update))
  (what-char what-char-current-char 1))

(defun what-char-add-to-mode-line (&optional buffer)
  "Add an entry for `what-char-mode' to `mode-line-format'.

If BUFFER is given, only the value for that buffer is modified.
Otherwise the default value is modified using `setq-default'.

This function may fail if `mode-line-format' is too complex."
  (interactive)
  (let ((elem '(what-char-mode ("" what-char-mode-line-format " ")))
		format)
	(cond ((stringp mode-line-format)
		   (setq format (list elem mode-line-format)))
		  ((listp mode-line-format)
		   (setq format (reverse mode-line-format))
		   (let ((sep (member "-%-" format)))
			 (if sep
				 (setcdr sep (cons elem (cdr sep)))
			   (setq format (cons elem format)))
			 (setq format (nreverse format))))
		  (t
		   (error "Unsupported form of `mode-line-format'")))
	(if buffer
		(with-current-buffer buffer
		  (setq mode-line-format format))
	  (setq-default mode-line-format format))
	(force-mode-line-update)))

(defvar what-char-mode-line-keymap
  (let ((parent-map (make-sparse-keymap))
		(child-map (make-sparse-keymap)))
	(define-key child-map [mouse-2] 'what-char-mouse-show)
	(define-key parent-map [mode-line] child-map)
	parent-map))

(if (boundp 'mode-line-mode-menu)
	(define-key mode-line-mode-menu [what-char-mode]
	  '(menu-item "What Character Code" what-char-mode
				  :button (:toggle . what-char-mode))))

(provide 'what-char)

;;; what-char.el ends here
