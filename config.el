(defvar elpaca-installer-version 0.5)
  (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
  (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
  (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
  (defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                          :ref nil
                          - :files (:defaults (:exclude "extensions"))
                          :build (:not elpaca--activate-package)))
  (let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
   (build (expand-file-name "elpaca/" elpaca-builds-directory))
   (order (cdr elpaca-order))
   (default-directory repo))
    (add-to-list 'load-path (if (file-exists-p build) build repo))
    (unless (file-exists-p repo)
      (make-directory repo t)
      (when (< emacs-major-version 28) (require 'subr-x))
      (condition-case-unless-debug err
    (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
             ((zerop (call-process "git" nil buffer t "clone"
                                   (plist-get order :repo) repo)))
             ((zerop (call-process "git" nil buffer t "checkout"
                                   (or (plist-get order :ref) "--"))))
             (emacs (concat invocation-directory invocation-name))
             ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                   "--eval" "(byte-recompile-directory \".\" 0 'force)")))
             ((require 'elpaca))
             ((elpaca-generate-autoloads "elpaca" repo)))
        (kill-buffer buffer)
      (error "%s" (with-current-buffer buffer (buffer-string))))
  ((error) (warn "%s" err) (delete-directory repo 'recursive))))
    (unless (require 'elpaca-autoloads nil t)
      (require 'elpaca)
      (elpaca-generate-autoloads "elpaca" repo)
      (load "./elpaca-autoloads")))
  (add-hook 'after-init-hook #'elpaca-process-queues)
  (elpaca `(,@elpaca-order))

  ;; Install use-package support
  (elpaca elpaca-use-package
    ;; Enable :elpaca use-package keyword.
    (elpaca-use-package-mode)
    ;; Assume :elpaca t unless otherwise specified.
    (setq elpaca-use-package-by-default t))

  ;; Block until current queue processed.
  (elpaca-wait)

  ;;When installing a package which modifies a form used at the top-level
  ;;(e.g. a package which adds a use-package key word),
  ;;use `elpaca-wait' to block until that package has been installed/configured.
  ;;For example:
  ;;(use-package general :demand t)
  ;;(elpaca-wait)

  ;;Turns off elpaca-use-package-mode current declartion
  ;;Note this will cause the declaration to be interpreted immediately (not deferred).
  ;;Useful for configuring built-in emacs features.
  ;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

  ;; Don't install anything. Defer execution of BODY
  ;;(elpaca nil (message "deferred"))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
    (setq evil-want-keybinding nil)
    (setq evil-vsplit-window-right t)
    (setq evil-split-window-below t)
    (evil-mode))
  (use-package evil-collection
    :after evil
    :after magit
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer magit))
    (evil-collection-init))
 
 (use-package evil-tutor)
 (setq ring-bell-function #'ignore)

(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer AY/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode


  (AY/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  (AY/leader-keys
    "d" '(:ignore t :wk "Display/Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d p" '(peep-dired :wk "Peep-dired")
    "d t" '(org-toggle-inline-images :wk "Toggle Inline Images")) 

  (AY/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e s" '(eshell :which-key "Eshell"))

  (AY/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "f r" '(counsel-recentf :wk "Find recent files")
    "TAB TAB" '(comment-line :wk "Comment lines")
    "TAB u" '(comment-dwim :wk "Comment-Do What I Mean")
    "f a" '((lambda () (interactive) (find-file "~/Desktop/Work/Agenda.org")) :wk "Work Agenda"))

  (AY/leader-keys
    "g" '(:ignore t :wk "Magit")
    "g c" '(magit-commit :wk "Magit commit")
    "g s" '(magit-stage-buffer-file :wk "Magit stage buffer file")
    "g g" '(magit-status :wk "Magit status"))


  (AY/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    "h r r" '(reload-init-file :wk "Reload emacs config"))

  (AY/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (AY/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (AY/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (AY/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t q" '(visual-line-mode :wk "Toggle truncated lines")
    "t t" '(treemacs :wk "Toggle treemacs")
    "t d" '(treemacs-select-directory :wk "Open treemacs in dir..")
)


  (AY/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

;; Org Mode keybindings
  (AY/leader-keys
    ">" '(:ignore t :wk "Org Export")
    "> e" '(org-export-dispatch :wk "Export Org File")
   )



)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

;; (use-package all-the-icons-dired
;;   :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(add-hook 'org-mode-hook #'company-mode)

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.config/emacs/images/Emacs-logo.svg")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
;;  (dashboard-modify-heading-icons '((recents . "file-text")
                         ;;     (bookmarks . "book")))
  (setq dashboard-banner-logo-title  "Emacs is a fully hackable system")

  (setq dashboard-footer-messages 
  '(
    "قول صدق، في لوب؟"
    "Two Words: Org Mode"
    "I’m out of my mind"
    "There we go"
    "اه لا اصحك"
    "Self-defeating Loops" 
    "هو السيريتونن"
    "هذا ولد طاير"
    "وهيك يا سيدي بكون عنا ستوند آيب"
    "Language fails"
    "This separates the intrepid from the casual, believe me"
    "انطيني بايب القدس"
    "خلني أشرحلك"
    "والحمد لله رب العالمين"
  ))
  :config
  (dashboard-setup-startup-hook))

(use-package dired-open

  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :hook 
    (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 140
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "Ubuntu"
  :height 140
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 130
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-14"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package jupyter
  :ensure t
  :config
  (require 'jupyter))

;;Setting up a few keybindings to use in ein (NOTE: these keybindings only work when in ein mode)
(with-eval-after-load 'evil
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-t") 'ein:worksheet-change-cell-type) ;toggles type of block (code<->mkdn)
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-b") 'ein:worksheet-insert-cell-below)
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-a") 'ein:worksheet-insert-cell-above)
  (evil-define-key '(normal)  ein:notebook-mode-map (kbd "dd") 'ein:worksheet-kill-cell)
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-s") 'ein:notebook-save-notebook-command-km)
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-r") 'ein:worksheet-execute-cell)
  (evil-define-key '(normal insert visual) ein:notebook-mode-map (kbd "M-a") 'ein:worksheet-execute-all-cells)
)

;;Toggling line numbers to be always on while using notebook (.ipynb file)——for some reason they keep turning off
(defun my-ein-setup ()
  "My setup for ein:notebook-mode."
  (display-line-numbers-mode 1))
(add-hook 'ein:notebook-mode-hook 'my-ein-setup)
(setq ein:worksheet-enable-undo t)

(tool-bar-mode -1)
(scroll-bar-mode -1)
;;setting default window size on open up
;;(add-to-list 'default-frame-alist '(width . 214))   ; Set the width (in characters)
;;(add-to-list 'default-frame-alist '(height . 59))   ; Set the height (in lines)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(setq display-line-numbers-type 'relative)

(defun alrayyes/evil-yank-advice (orig-fn beg end &rest args)
  (pulse-momentary-highlight-region beg end)
  (apply orig-fn beg end args))

(advice-add 'evil-yank :around 'alrayyes/evil-yank-advice)

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package haskell-mode)
(use-package lua-mode)

(use-package magit
  :ensure t)

;;need to use evil-collection for evil mode to work properly with magit status buffer

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(require 'org-tempo)

(setq org-hide-emphasis-markers t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
    (python . t)
    (C . t) ;includes C++
    (R .t)
    (latex . t)
    (js . t)
    (css . t)
    (matlab . t)
    (java . t)
    (sql . t)
    (shell . t)
 ))

;;made it so that you don't have to input "python3" manually everytime you want a python code block
(add-to-list 'org-babel-default-header-args:python
             '(:python . "python3"))

;;made it so that exporting includes both code block + result
(setq org-babel-default-header-args
      (cons '(:exports . "both")
            (assq-delete-all :exports org-babel-default-header-args)))

(global-set-key (kbd "M-p")  'org-edit-special)
(global-set-key (kbd "M-;")  'org-edit-src-exit)
(global-set-key (kbd "M-r")  'org-ctrl-c-ctrl-c)

;;installing package to display latex in-line immediately after typing it
(use-package org-fragtog)

(add-hook 'org-mode-hook 'org-fragtog-mode)

;;tweaking some settings to fix exporting org docs
(setq-default org-export-with-broken-links t)
(setq-default org-export-with-toc t)
(setq-default org-confirm-babel-evaluate nil)

(use-package projectile
  :config
  (projectile-mode 1))

;Defining scan line size
(defcustom num-lines 30 "Number of lines to use for custom quick navigation scanning"
  :type 'integer
  :group 'my-custom-group)

;Defining function
(defun scan-up()
  (interactive)
  (previous-line num-lines))
(defun scan-down()
  (interactive)
  (next-line num-lines))

;Adding keybindings
(global-set-key (kbd "M-k") 'scan-up)
(global-set-key (kbd "M-j") 'scan-down)

(use-package rainbow-mode
  :hook org-mode prog-mode
  :diminish)

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
  
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package sudo-edit
  :config
    (AY/leader-keys
      "fu" '(sudo-edit-find-file :wk "Sudo find file")
      "fU" '(sudo-edit :wk "Sudo edit file")))

;;enabling tab bar mode by default
(setq tab-bar-mode t)
(setq tab-bar-history-mode t)

;;keybindbing for closing current tab
(global-set-key (kbd "M-w") 'tab-close)

;;keybinding for opening new tab 
(global-set-key (kbd "M-n") 'tab-new)

;;keybinding for opening recently closed tab
(global-set-key (kbd "M-t") 'tab-undo)

;;keybinding for cycling through tabs (it wraps around if it reaches end)
(global-set-key (kbd "M-/") 'tab-bar-switch-to-next-tab)

;maximize window on startup
(add-to-list 'initial-frame-alist '(fullscreen . fullscreen))


      ;THEME 1 (SRCERY)
              ;; (use-package srcery-theme
              ;; :ensure t
              ;; :config
              ;; (load-theme 'srcery t))

      ;THEME 2 (VSCODE DARK)

      ;; (use-package vscode-dark-plus-theme
      ;;   :ensure t
      ;;   :config
      ;;   (load-theme 'vscode-dark-plus t))

    ;;THEME 3 (doom themes)
    ;;A bunch of themes from: https://github.com/doomemacs/themes
    ;;some good ones: doom-fairy-floss, doom-dracula 
    ;; (use-package doom-themes
    ;;   :ensure t
    ;;   :config
    ;;   ;; Global settings (defaults)
    ;;   (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
    ;;         doom-themes-enable-italic t) ; if nil, italics is universally disabled
    ;;   (load-theme 'doom-dracula	 t)

    ;;   ;; Enable flashing mode-line on errors
    ;; ;;  (doom-themes-visual-bell-config)
    ;;   ;; Enable custom neotree theme (all-the-icons must be installed!)
    ;; ;;  (doom-themes-neotree-config)
    ;;   ;; Corrects (and improves) org-mode's native fontification.
    ;;   (doom-themes-org-config))

;THEME 4 (Dracula theme)
;;installing melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'dracula t)

;;below code makes emacs window tranlucent (only works while window is not fullscreen)

;(set-frame-parameter (selected-frame) 'alpha '(85 . 50)) ;for current frame
;(add-to-list 'default-frame-alist '(alpha . (85 . 50))) ;for all frames (default value)

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t
  :config
(evil-define-key 'treemacs treemacs-mode-map (kbd "w") #'treemacs-select-window)) 

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
  which-key-sort-order #'which-key-key-order-alpha
  which-key-sort-uppercase-first nil
  which-key-add-column-padding 1
  which-key-max-display-columns nil
  which-key-min-display-lines 6
  which-key-side-window-slot -10
  which-key-side-window-max-height 0.25
  which-key-idle-delay 0.8
  which-key-max-description-length 25
  which-key-allow-imprecise-window-fit nil
  which-key-separator " → " ))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;(package-initialize)

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))

(setq evil-undo-system 'undo-tree)
