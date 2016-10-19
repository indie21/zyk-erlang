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

(setq zyk-packages
      '(
        erlang
        ))



;;----------------------------------------------------------------------------
;; 让你的上下左右键可以用来切换窗口
;;----------------------------------------------------------------------------

(when (fboundp 'winner-mode)
  (winner-mode 1))
(windmove-default-keybindings)
(global-set-key (kbd "<f7> ") 'winner-undo)


;;----------------------------------------------------------------------------
;; Org模式
;;----------------------------------------------------------------------------

;;显示不够的内容。自动换行.
(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))
(setq org-agenda-files (list "~/source/gtd"  ))

;;org-mode 和winner模式冲突.
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)



;;----------------------------------------------------------------------------
;; 习惯按键设置
;;----------------------------------------------------------------------------

(global-set-key (kbd "C-c C-c")   'comment-region)
(global-set-key (kbd "C-c C-u")   'uncomment-region)

(global-set-key (kbd "C-q") 'backward-kill-word)
(global-set-key (kbd "C-c C-f") 'goto-line)

(global-set-key (kbd "M-|") 'indent-region)
(global-set-key (kbd "M-h") 'mark-paragraph)



;;----------------------------------------------------------------------------
;; 桌面保存
;;----------------------------------------------------------------------------

(desktop-save-mode)
;; 不再提示 You appear to be setting environment variables ("PATH" "MANPATH")
;; in your .bashrc or .zshrc
(setq exec-path-from-shell-check-startup-files nil)

;;----------------------------------------------------------------------------
;; 打开大文件
;;----------------------------------------------------------------------------

(defun large-file-hook ()
  "If a file is over a given size, make the buffer read only."
  (when (> (buffer-size) (* 2 1024 1024))
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (buffer-disable-undo)
    (linum-mode 0)
    (font-lock-mode 0)
    (fundamental-mode)))



;;----------------------------------------------------------------------------
;; eclim
;;----------------------------------------------------------------------------

(setq eclim-eclipse-dirs "/Applications/Eclipse.app/Contents/Eclipse/"
      eclimd-executable "/Applications/Eclipse.app/Contents/Eclipse/eclimd"
      eclim-executable "/Applications/Eclipse.app/Contents/Eclipse/eclim")



;;----------------------------------------------------------------------------
;; erlang
;;----------------------------------------------------------------------------


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
                  (setq indent-tabs-mode nil)
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
