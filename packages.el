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
    alchemist
    ;;distel
    ))

(defun zyk-erlang/post-init-company ()
  (add-hook 'erlang-mode-hook 'company-mode))

(set-default 'indent-tabs-mode nil)


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


;; erlang specific
(setq flycheck-erlang-include-path (list "../include"
                                         "../../include"
                                         "../../../include"
                                         "../../../../include"
                                         "../../../../../include"
                                         "../deps/rabbit_common/include"
                                         "../deps/lager/include"
                                         "/Users/zhuoyikang/source/slash/apps/proto/include"

                                         "/Users/zhuoyikang/source/services/ejabberd_install/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/deps/esip/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/deps/fast_xml/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/deps/lager/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/deps/p1_xmlrpc/include"
                                         "/Users/zhuoyikang/source/services/ejabberd/deps/stun/include"

                                         "/Users/zhuoyikang/source/vcity/apps/proto/include"
                                         "../deps/proto/include"))

(setq flycheck-erlang-library-path (list "ebin" "../ebin"  "../../ebin"  "../../../ebin" "../deps/*/ebin" ))

(setenv "ERL_LIBS" "/Users/zhuoyikang/source/vcity/deps")

(defvar rebar-directory "gl_online"
  "匹配这个正则表达式的路径将会认为是工作文件夹,工作文件夹下的erlang文件被保存时触发自动编译.")


(setq rebar-directory  (list "vcity" "slash"))


(setq beam_sync_list "/Users/zhuoyikang/Source/gl2/gl1x/")
(setq beamHash (make-hash-table :test 'equal))


;; 保存erlang文件时直接编译.
(defun rebar-compile-source ()
  "编译当前缓冲区的文件，在文件保存后执行."
  (let ((buffer-name (buffer-file-name (current-buffer)))
        (match-pos nil)(full-path nil)
        (compile-cmd nil)(list-directory rebar-directory)
        (match-directory nil))
    (if (string-equal "erl" (file-name-extension buffer-name))
        (progn
          (while (and  (car list-directory)  (equal nil match-directory))
            (if (string-match (car list-directory) buffer-name)
                (setq  match-directory (car list-directory)))
            (setq list-directory (cdr list-directory)))
          (if (and match-directory (string-match match-directory buffer-name))
              (progn
                (setq match-pos (string-match match-directory buffer-name))
                (setq full-path (substring buffer-name 0 match-pos))
                (setq compile-cmd  (concat
                                    "erlc  -pa /Users/zhuoyikang/source/vcity/deps/lager/ebin "
                                    " +'{parse_transform, lager_transform}' "
                                    "-o " full-path
                                    match-directory "/ebin/" " -Wall "
                                    "-I " full-path match-directory "/include "
                                    "-I " full-path match-directory "/apps/proto/include "
                                    "-pa " full-path match-directory "/ebin "
                                    buffer-name
                                    ))
                (shell-command compile-cmd "*Messages")
                (message compile-cmd  "*Messages")
                ;; (beam_hash_cp_key (concat full-path match-directory "/ebin/"
                ;;                           (replace-regexp-in-string ".erl" ".beam" (buffer-name))
                ;;                           ))
                )
            )
          )
      )
    )
  )


(defun read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))


;; 循环遍历copy
(defun beam_hash_cp_key(key)
  ;;(message key)
  (let ((value (gethash key beamHash)))
    (while (car value)
      (let ((v1 (car value)))
        (progn ()
               (setq compile-cmd  (concat  "cp " key " " v1))
               (shell-command compile-cmd "*Messages")
               (message compile-cmd "*Messages")
               )
        )
      (setq value (cdr value))
      )
    )
  )



(defun load_beam_hash ()
  (let ((list (read-lines (concat beam_sync_list "scripts/.sync.sh")))
        )
    (while (car list)
      ;;(message (car list) "*Messages")
      (let ((scp (split-string  (car list)))
            )
        (if (> (length (list scp)) 0)
            (progn
              ;;(message (concat beam_sync_list (nth 1 scp)) "*Messages")
              (puthash (concat beam_sync_list (nth 1 scp))
                       (push (concat beam_sync_list (nth 2 scp)) (gethash (concat beam_sync_list (nth 1 scp)) beamHash))
                       beamHash)
              )
          )
        )
      (setq list (cdr list)))
    )
  )


(add-hook 'after-save-hook 'rebar-compile-source)



(defun ops()
  (interactive)
  (progn
    (find-file-existing "~/source")
    )
  )



(setq erlang-indent-level 4)
