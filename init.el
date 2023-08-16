(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
(put 'erase-buffer 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dashboard-footer-messages
   '("قول صدق، في لوب؟" "Two Words: Org Mode" "I’m out of my mind" "There we go" "اه لا اصحك" "Self-defeating Loops" "Emacs is a fully hackable system" "هو السيريتونن" "هذا ولد طاير"))
 '(ein:jupyter-server-use-subcommand "server")
 '(org-agenda-files '("~/Desktop/Work/Agenda.org"))
 '(package-selected-packages '(ein mpv dracula-theme undo-tree markdown-mode))
 '(warning-suppress-types
   '((emacs)
     ((package reinitialization))
     ((package reinitialization)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
