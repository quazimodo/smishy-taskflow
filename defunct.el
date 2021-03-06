
(defun smishy-reload-top ()
  "Prepare new Next Action line.
This function will jump to line smishy-work-line, newline it and then put a * NEXT ACTION line in and get ready for input."
  (interactive)
  ;; (switch-to-buffer "biglist.org")
  (delete-other-windows)
  (goto-line smishy-work-line)
  (setq mystr (buffer-substring (point-at-bol) (point-at-eol)))
  (cond ((string= mystr "* NEXT ACTION ") (move-end-of-line 1))
        ((string= mystr "* NEXT ACTION")
         (move-beginning-of-line 1)
         (kill-line)
         (insert "* NEXT ACTION "))
        ((string= mystr "")
         (move-beginning-of-line 1)
         (kill-line)
         (newline)
         (goto-line smishy-work-line)
         (insert "* NEXT ACTION "))
        ((string-match "^ +$" mystr) ;tests for 1 or more blank spaces only
         (move-beginning-of-line 1)
         (kill-line)
         (newline)
         (goto-line smishy-work-line)
         (insert "* NEXT ACTION "))
        (t
         (move-beginning-of-line 1)
         (newline)
         (goto-line smishy-work-line)
         (insert "* NEXT ACTION ")))
  (goto-line (+ 1 smishy-work-line))
  (if (string-match "\* NEXT ACTION ." mystr)
      (org-todo "TODO"))
  (setq mystr2 (buffer-substring (point-at-bol) (point-at-eol)))
  (goto-line (+ 2 smishy-work-line))
  ;; This bit processes the 2nd line under the work line and turns it into a
  ;; TODO which doesn't really seem to be a good thing
  ;; (if (and (string-match "\* TODO " mystr2)
  ;;          (string-match "\* NEXT ACTION ." mystr))
  ;;     (org-todo "TODO"))
  (goto-line smishy-work-line)
  (move-end-of-line 1)
  (save-buffer))

(defun smishy-save-n-go ()
  "Save new Next Action and clone frame.
Push the current task down, add a new DOING, then save the whole file. Finally, detach the screen, thus killing the xterm."
  (interactive)
  (smishy-reload-top)
  (save-buffer)
  (shell-command "screen -D smishy-taskflow"))

(defun smishy-kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

(defun smishy-set-variables ()
  "Set important smishy-taskflow variables."
  (setq smishy-work-line 9) ;set what line you will be entering your task
  (setq org-agenda-custom-commands
        (append org-agenda-custom-commands
                '(("h" "2 week agenda, DONE and TODOs"
                   ((agenda "" ((org-agenda-start-on-weekday nil)))
                    (todo "DONE")
                    (todo "DELETED")
                    (todo "TODO"))))))
  (setq org-lowest-priority 69)
  (setq org-default-priority 68)
  (setq org-stuck-projects '("{^.*}/PROJECT" ("TODO" "DOING") nil "")))

(defun smishy-set-faces ()
  "Set smishy-taskflow faces."
  (setq org-todo-keywords '((type "NEXT ACTION" "DOING" "TODO" "PROJECT" "DEFERRED" "DELEGATED" "REF" "NOTE" "|" "DONE" "DELETED")))
  ;; Use hex values for terminal and gui color support
  (setq org-todo-keyword-faces
        '(("NEXT ACTION" . (:foreground "#000000" :background "#ffff00"))
          ("DOING" . (:foreground "#000000" :background "#cdcd00"))
          ("TODO" . (:foreground "#ffffff" :background "#cd00cd"))
          ("PROJECT" . (:foreground "#000000" :background "#5fff00"))
          ("DEFERRED" . (:foreground "#000000" :background "#af5f00"))
          ("DELEGATED" . (:foreground "#000000" :background "#5fffd7"))
          ("REF" . (:foreground "#000000" :background "#bebebe"))
          ("NOTE" . (:foregroud "#cd0000" :background "#af005f"))
          ("DONE" . (:foreground "#5f0000" :background "#ffffff"))
          ("DELETED" . (:foreground "#ff0000" :background "#870000"))))
  (custom-set-faces
   '(org-tag ((t (:foreground "#000000" :background "#5fff00"))))
   '(org-level-1 ((t (:foreground "#ffffff"))))
   '(org-special-keyword ((t (:foreground "#ff00ff" :background "#00005f"))))))

(defun smishy-set-key-bindings ()
  "Set smishy-taskflow key-bindings.
Sets keys for org-mode-map and org-agenda-mode-map.
   ',.p y|f gcrl
   aoeu i|d htns
    qjk x|b mwvz "
  (define-key org-mode-map (kbd "C-c C-c") 'smishy-insert-todo)
  (define-key org-mode-map (kbd "C-c C-d") 'org-deadline)
  (define-key org-mode-map (kbd "C-c C-h") 'org-schedule)
  (define-key org-mode-map (kbd "C-c C-t") 'org-set-tags)
  (define-key org-mode-map (kbd "C-c C-l") 'org-store-link)

  (define-key org-mode-map (kbd "C-c e") 'smishy-reload-tasks)
  (define-key org-mode-map (kbd "C-c p") 'smishy-create-project)
  (define-key org-mode-map (kbd "C-c c") 'smishy-reload-top)
  (define-key org-mode-map (kbd "C-c r") 'org-clock-goto)
  (define-key org-mode-map (kbd "C-c a") 'org-agenda)
  (define-key org-mode-map (kbd "C-c o") 'org-clock-out)
  (define-key org-mode-map (kbd "C-c i") 'org-clock-in)
  (define-key org-mode-map (kbd "C-c d") 'smishy-toggle-done)
  (define-key org-mode-map (kbd "C-c h") (lambda () (interactive) (org-agenda nil "h")))
  (define-key org-mode-map (kbd "C-c t") (lambda () (interactive) (org-todo-list "TODO")))
  (define-key org-mode-map (kbd "C-c n") (lambda () (interactive) (org-agenda-list 56)))
  (define-key org-mode-map (kbd "C-c s") 'smishy-save-n-go)
  (define-key org-mode-map (kbd "C-c b") 'org-iswitchb)

  ;; The following keybinds are for when emacs is in an xterm, shift + direction
  ;; keys return ESC [ 1 ; 2 bla  for some reason (reason is found in ECMA-48) ;;
  (define-key org-mode-map (kbd "ESC [ 1 ; 2 D") (kbd "<S-left>"))
  (define-key org-mode-map (kbd "ESC [ 1 ; 2 C") (kbd "<S-right>"))
  (define-key org-mode-map (kbd "ESC [ 1 ; 2 A") (kbd "<S-up>"))
  (define-key org-mode-map (kbd "ESC [ 1 ; 2 B") (kbd "<S-down>"))
  (define-key org-agenda-mode-map (kbd "TAB") 'smishy-tab-out-of-agenda))

(defun smishy-toggle-done ()
  "Toggle ACTION/DONE on current line.
Finish task on the current line and save it at the bottom as 'DONE'"
  (interactive)
  (setq mystr (buffer-substring (point-at-bol) (point-at-eol)))
  (cond ((string-match "^\** ACTION " mystr) (org-todo "DONE"))
        ((string-match "^\** DONE " mystr) (org-todo "ACTION"))
        ((string-match "^\** PROJECT " mystr) (org-todo "CLOSED"))
        ((string-match "^\** CLOSED " mystr) (org-todo "PROJECT"))))

(defun smishy-set-max-priority()
  "Set the current TODO to have the maximum priority"
  (let* ((marker (or (org-get-at-bol 'org-hd-marker)
                     (org-agenda-error)))
         (buffer (marker-buffer marker)))
    (with-current-buffer buffer
      (save-excursion
        (save-restriction
          (widen)
          (goto-char marker)
          (org-back-to-heading t)
          (org-priority 65))))))

(defun smishy-tab-out-of-agenda (&optional highlight)
  "Tab out of agenda view easily.
Used to tab out of the agenda view when the marker is not on a todo, which org-mode usually responds to by throwing an error."
  (interactive)
  (if (org-get-at-bol 'org-marker) ; true if org-marker
      (org-agenda-goto highlight) ; continue as normal
    (smishy--tab-out-of-agenda-list))) ; open list

(defun smishy--tab-out-of-agenda-list ()
  "Create popup list to tab out of agenda view.
Usually called by smishy-tab-out-of-agenda, this function either creates a list of org files that org-agenda knows about, or tabs out to it if only 1 is known."
  (let* ((file-path (cond ((equal 1 (length org-agenda-files))
                           (car org-agenda-files))
                          ((< 1 (length org-agenda-files))
                           (popup-menu* org-agenda-files))))
         (buffer (get-file-buffer file-path)))
    (if buffer
        (switch-to-buffer-other-window buffer)
      (find-file-other-window file-path))))

(defun smishy-create-project ()
  "Create an Org-Mode project.
Creates an Org-Mode project, then allows you to insert a ACTION"
  (interactive)
  (if (equal (line-number-at-pos) smishy--work-line)
      (goto-line (+ smishy--work-line 1)))
  (org-insert-todo-heading nil)
  (org-todo "PROJECT"))
