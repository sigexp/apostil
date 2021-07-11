;; apostil.el --- assign notes to words -*- lexical-binding: t -*-
;; Copyright © 2021 Yevhenii Kolesnikov
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;; Author: Yevhenii Kolesnikov
;; Maintainer: Yevhenii Kolesnikov
;; Created: 11.07.2021
;; Version: 0.1
;; Keywords: convenience, annotation

(defgroup apostil nil
  "Apostil allows to assign notes to words."
  :group 'convenience)

(define-minor-mode apostil-mode
  "Toggle apostil mode.

Apostil mode allows to assign buffer-local descriptive notes to words."
  :group 'apostil
  :keymap (let* ((map (make-sparse-keymap)))
            (define-key map (kbd "M-s a .")   'apostil-add-note-at-point)
            (define-key map (kbd "M-s a w")   'apostil-add-note-for-word)
            (define-key map (kbd "M-s a RET") 'apostil-get-note-at-point)
            (define-key map (kbd "M-s a g")   'apostil-get-note-for-word)
            (define-key map (kbd "M-s a <backspace>")
              'apostil-unset-note-at-point)
            (define-key map (kbd "M-s a u")   'apostil-unset-note-for-word)
            map))

(defvar apostil-mode-hook nil)

(defvar apostil-list nil
  "Holds a list of pairs of the form (word . note)")
(make-variable-buffer-local 'apostil-list)

(defun apostil-add-note (word note)
  "Add a new note to the list. Change the note, if already set."
  (defun iter (list-iter)
    (cond ((null list-iter) nil)
          ((string-match (caar list-iter) word) (setcdr (car list-iter) note))
          (t (iter (cdr list-iter)))))
  (when (null (iter apostil-list))
    (add-to-list 'apostil-list (cons word note))))

(defun apostil-add-note-at-point ()
  "Add a new note to the word at point."
  (interactive)
  (let* ((word (symbol-name (symbol-at-point)))
         (prompt (format "Note for %s: " word))
         (note (read-string prompt)))
    (apostil-add-note word note)))

(defun apostil-add-note-for-word ()
  "Asks for a word and adds a note for it."
  (interactive)
  (let* ((word (read-string "Add a note for: "))
         (prompt (format "Note for %s: " word))
         (note (read-string prompt)))
    (apostil-add-note word note)))

(defun apostil-get-note (word)
  "Returns the note for a word, if any. Otherwise returns nil."
  (defun iter (list-iter)
    (cond ((null list-iter) nil)
          ((string-match (caar list-iter) word) (cdar list-iter))
          (t (iter (cdr list-iter)))))
  (iter apostil-list))

(defun apostil-get-note-at-point ()
  "Prints note for a word at point"
  (interactive)
  (let* ((word (symbol-name (symbol-at-point)))
         (note (apostil-get-note word)))
    (message "%s" note)))

(defun apostil-get-note-for-word ()
  "Asks for a word and prints note for it"
  (interactive)
  (let* ((word (read-string "Get note for: "))
         (note (apostil-get-note word)))
    (message "%s" note)))

(defun apostil-unset-note (word)
  "Unset a note for the word"
  (defun iter (list-iter)
    (cond ((null list-iter) nil)
          ((string-match (caar list-iter) word)
           (setq apostil-list (remove (car list-iter) apostil-list)))
          (t (iter (cdr list-iter)))))
  (iter apostil-list))

(defun apostil-unset-note-at-point ()
  "Unset a note for the word at point"
  (interactive)
  (let* ((word (symbol-name (symbol-at-point))))
    (apostil-unset-note word)))

(defun apostil-unset-note-for-word ()
  "Asks for a word and unsets the note for it"
  (interactive)
  (let* ((word (read-string "Unset note for: ")))
    (apostil-unset-note word)))

(provide 'apostil)
