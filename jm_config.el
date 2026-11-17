;; -*- lexical-binding: t; -*-
(load-theme 'modus-vivendi t)

;; (with-eval-after-load 'python
;;   (setq python-shell-interpreter "ipython"
;;         python-shell-interpreter-args "-i --simple-prompt --colors=NoColor --pprint")
;;   ;; Reclaim C-c C-f for sending the function definition to the REPL
;;   (define-key python-mode-map (kbd "C-c C-f") 'python-shell-send-defun))

(use-package python
  :defer t
  :custom
  (python-shell-interpreter "ipython")
  (python-shell-interpreter-args "-i --simple-prompt --colors=NoColor --pprint")
  :bind
  (:map python-mode-map
        ("C-c C-f" . python-shell-send-defun)))

;; Ensure perspective is installed
;; Ensure both required packages are downloaded and installed
;;(prelude-require-package 'perspective)

(use-package perspective
  :ensure t
  :custom
  ;; Set perspective prefix
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init
  (persp-mode 1) ; This starts the original perspective minor mode
  :config
  ;; The original perspective package will now start perfectly clean
  ;; and won't remember your buffers from the previous session.
  )

;;(with-eval-after-load 'whitespace
;;  (setq whitespace-style (delq 'lines-tail whitespace-style))
;;  (setq whitespace-style (delq 'lines whitespace-style)))
;;

(use-package whitespace
  :config
  (setq whitespace-style (delq 'lines-tail whitespace-style))
  (setq whitespace-style (delq 'lines whitespace-style)))

;; fun and games
;;(with-eval-after-load 'zone
;;  (setq zone-programs [zone-pgm-drip])) ; always run the matrix style char drop
;;(zone-when-idle 300) ; 300 seconds

(use-package zone
  :functions zone-when-idle
  :config
  (setq zone-programs [zone-pgm-drip])
  (zone-when-idle 300)) ; 5 minutes

;; grip show markdown preview in browser,  mermaid, et
(use-package grip-mode
  :ensure t
  :defer t
  :commands (grip-mode)
  :bind (:map markdown-mode-map
              ("C-c C-g" . grip-mode))
  :config
  ;; Optional: Add GitHub credentials to avoid rate limits on image/API rendering
  ;; (setq grip-github-user "your-username")
  ;; (setq grip-github-password "your-personal-access-token")
  )

;; Define dependencies and main package for agentic processing

;; 1. Ensure dependencies are pulled from MELPA automatically
(defvar my-agent-packages '(shell-maker acp agent-shell)
  "List of packages required to run the agent-shell runtime interface.")

(dolist (pkg my-agent-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; 2. REFACTORED MAC-COMPLIANT BOOTSTRAPPED LAUNCHER

;; 1. Register the functions so the compiler knows they exist
(declare-function agent-shell--dwim "agent-shell")
;;(declare-function agent-shell-make-agent-config "agent-shell")
(declare-function agent-shell--make-acp-client "agent-shell")

(eval-when-compile
  (require 'agent-shell nil t))

(defun agent-shell-start-bob-agent ()
  "Initialize an interactive buffer connected to IBM Bob.

 Connects via a strict shell-maker layout."
  (interactive)
  (require 'agent-shell)
  (let* (;; 💡 CRITICAL MAC FIX A: Force find your absolute API key string via your native zsh shell profile environment.
         ;; This ensures GUI Emacs inherits your token without manual terminal loading hacks.
         (retrieved-key (or (getenv "BOBSHELL_API_KEY")
                            (string-trim (shell-command-to-string "zsh -lic 'echo $BOB_API_KEY'"))))
         ;; 💡 CRITICAL MAC FIX B: Explicitly find the absolute path to your binary so Emacs doesn't throw path errors.
         (bob-path (or (executable-find "bob")
                       (string-trim (shell-command-to-string "zsh -lic 'which bob'")))))

    ;; Operational Fallback Safeguard
    (if (string-empty-p retrieved-key)
        (user-error "Emacs Error: BOB_API_KEY was not found. Please export it inside your ~/.zshrc profile file")

      ;; Execute modern verified constructor layout safely
      (agent-shell--dwim
       :config
       (agent-shell-make-agent-config
        :identifier 'ibm-bob
        :mode-line-name "IBM Bob"
        :buffer-name "IBM Bob"
        :shell-prompt "Bob> "
        :shell-prompt-regexp "^Bob> "
        :client-maker (lambda (buffer)
                        (agent-shell--make-acp-client
                         :command bob-path
                         :command-params '("acp" "--accept-license" "--trust")
                         :environment-variables
                         (list (format "BOB_API_KEY=%s" retrieved-key))
                         :context-buffer buffer)))
       :new-shell t))))
