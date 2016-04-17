;;; packages.el --- Erlang Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq zyk-erlang-packages
  '(
    company
    erlang
    ;;distel
    ))

(defun zyk-erlang/post-init-company ()
  (add-hook 'erlang-mode-hook 'company-mode))


(defun zyk-erlang/init-erlang ()
  (use-package erlang
    :defer t
    :init
    (progn
      ;; explicitly run prog-mode hooks since erlang mode does is not
      ;; derived from prog-mode major-mode
      (add-hook 'erlang-mode-hook (lambda () (run-hooks 'prog-mode-hook)))
      (setq erlang-root-dir "~/source/erlang/18.3/erts-7.3")
      (add-to-list 'exec-path "~/source/erlang/18.3/erts-7.3/bin")
      (setq erlang-man-root-dir "~/source/erlang/18.3/erts-7.3/man")
      (add-hook 'erlang-mode-hook
                (lambda ()
                  (setq mode-name "Erlang")
                  (flycheck-mode)
                  (modify-syntax-entry ?_ "w") ;;让this_good连成一个单词处理
                  ;; when starting an Erlang shell in Emacs, with a custom node name
                  (setq-default indent-tabs-mode nil)
                  (setq inferior-erlang-machine-options '("-sname" "syl20bnr"))
                  ))
      (setq erlang-compile-extra-opts '(debug_info)))
    :config
    (require 'erlang-start)))

(defun zyk-erlang/post-init-erlang ()
  (progn
    (add-to-list 'load-path "~/source/distel/elisp")
    (require 'distel)
    (distel-setup)
    (setq derl-cookie "abc")
    (setq erl-nodename-cache 'develop@127.0.0.1)
    )
  )


(setq erlang-indent-level 2)
