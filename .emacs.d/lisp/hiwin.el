;;; hiwin.el --- Visible active window mode. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2009 k.sugita
;;               2010 tomoya <tomoya.ton@gmail.com>
;;               2011 k.sugita <ksugita0510@gmail.com>
;;               2016 ril
;;
;; Author: k.sugita
;; Keywords: faces, editing, emulating
;; Version: 2.2.0
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Usage
;;
;; put followings your .emacs
;;   (require 'hiwin)
;;   (hiwin-activate)
;;   (set-face-background 'hiwin-face "gray80")
;;
;; if you want to ignore the *eshell* buffer,
;; put followings:
;;   (add-to-list 'hiwin-ignore-buffer-names "*eshell*")
;;
;; if you invisible active window, type M-x hiwin-deactivate.

;;; Changes
;;
;; 2022-06-29
;; - 下記のの変更によりVersionを2.2.0に変更した.
;;
;; 2022-06-28 ril
;; - `select-window'のNORECORD optionをtにして記録されないようにした.
;; - ミニバッファ直前のウィンドウを除外するかどうか選べるようにした.
;;   `hiwin-ignore-minibuffer-selected-window'がnon-nilのとき除外.
;;   デフォルトはnilで除外しない.
;; - `post-command-hook'ではなく`window-configuration-change-hook'
;;   にhookするようにした.  これで十分.
;;
;; 2022-06-27 ril
;; - Emacs 27以上の対応として `hiwin-face'に :extend t を追加.
;; - DocumationとCommnetをわかりやすいように変更.
;; - Versionを2.1.0に変更し, `hiwin-version'を追加.
;;
;; 2016-02-07 ril
;; - 変数名や関数名をいろいろと変更.
;; - ポイントがバッファの最後にある場合の対策
;; - 描画対象外バッファの設定を実装.
;;   `hiwin-ignore-buffer-names'から生成された正規表現
;;   `hiwin-ignore-buffer-name-regexp'にマッチするか否かで判定する.
;;
;; 2011-12-23 k.sugita
;; tails-marks.elを参考に以下の実装を見直し，修正
;; - ウィンドウ分割したとき，あるいはウィンドウ移動したとき
;;   オーバーレイを再作成するように修正
;; - 読み込み専用バッファの背景色を変更する処理を削除
;; - 非アクティブウィンドウの配色をフェイスで設定
;; - 描画対象外バッファの設定は未実装
;;
;; 2010-08-13 k.sugita
;; *Completions*表示時にMiniBufの表示が崩れるのを修正
;; 手動で画面リフレッシュできるようhiwin-refresh-winをinteractive化
;; 個人的な設定だったため，recenterのadviceを削除
;;
;; 2010-07-04 k.sugita
;; ローカルで再スクラッチしたファイルに tomoya氏，masutaka氏の修正を反映
;; readonlyなアクティブwindowの背景色を設定できるように機能変更
;;
;; 2010-06-07 tomoya
;; マイナーモード化
;;
;; 2009-09-13 k.sugita
;; ブログで公開
;; http://ksugita.blog62.fc2.com/blog-entry-8.html

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:

(defgroup hiwin nil
  "Visible active window mode."
  :group 'emacs)

(defconst hiwin-version "2.2.0"
  "Version number of hiwin-mode.")

(defcustom hiwin-mode-lighter " hiwin"
  "Lighter of hiwin-mode."
  :type 'string
  :group 'hiwin)

(defcustom hiwin-ignore-minibuffer-selected-window nil
  "もしこの変数が non-nil であれば,ミニバッファ直前のウィンドウをハイライト対象外にする."
  :type 'boolean
  :group 'hiwin)

(defcustom hiwin-ignore-buffer-names '("+draft/" "*helm")
  "ハイライト対象外にするバッファ名のリスト.
バッファ名にこのリストの文字列が含まれるとき,
非アクティブウィンドウに表示されていても背景色を変えない."
  :type 'list
  :group 'hiwin)

(defvar hiwin-ignore-buffer-name-regexp nil
  "ハイライト対象外のバッファ名の正規表現.
`hiwin-refresh-ignore-buffer-names'によって,
`hiwin-ignore-buffer-names'から生成される.")

(defface hiwin-face
  `((t ,@(and (>= emacs-major-version 27) '(:extend t))
       :background "gray25"))
  "非アクティブウィンドウのオーバーレイ描画用のフェイス.
Face for inactive window.")

(defvar hiwin-overlay-count nil
  "非アクティブウィンドウのオーバーレイ数.
現在のウィンドウ数に等しい.")

(defvar hiwin-active-window nil
  "再描画時のアクティブウィンドウ.")

(defvar hiwin-eob-overlay-lines 96
  "非アクティブウィンドウの末尾に挿入するフェイス付きの空行の行数.")

(defvar hiwin-overlays nil
  "非アクティブウィンドウのオーバーレイ.")

(defun hiwin-create-ovl ()
  "オーバレイを作成する."
  (let (
        (hw-temp-buf nil)               ; 作業用バッファ
        (hw-cnt 0)                      ; ループカウンタ
        )
    ;; オーバーレイ作成済みの場合はスキップ
    (unless hiwin-overlays
      (progn
        ;; 現在のウィンドウ数から作成するオーバーレイ数を決定
        (setq hiwin-overlay-count (count-windows))
        ;; 作業用バッファを作成
        (setq hw-temp-buf (get-buffer-create " *hiwin-temp*"))
        ;; 指定個数のオーバーレイを作成
        (while (< hw-cnt hiwin-overlay-count)
          ;; オーバーレイを作成
          (setq hiwin-overlays
                (cons (make-overlay 1 1 hw-temp-buf nil t) hiwin-overlays))
          ;; 作成したオーバレイにフェイスを設定
          (overlay-put (nth 0 hiwin-overlays) 'face 'hiwin-face)
          ;; 作成したオーバレイのEOB (End Of Buffer) のフェイスを設定.
          ;; propertizeでfaceが付加された改行"\n"を
          ;; overlayによってbufferの末尾に,
          ;; `hiwin-eob-overlay-lines'で指定された行数挿入
          (overlay-put (nth 0 hiwin-overlays) 'after-string
                       (propertize
                        (make-string hiwin-eob-overlay-lines ?\n) 'face 'hiwin-face))
          ;; カウンタアップ
          (setq hw-cnt (1+ hw-cnt))
          )
        ;; 作業用バッファを削除
        (kill-buffer hw-temp-buf)
        ))
    ))

(defun hiwin-delete-ovl ()
  "オーバレイを削除する."
  (let (
        (hw-cnt 0)                      ; ループカウンタ
        )
    ;; オーバーレイ未作成の場合はスキップ
    (when hiwin-overlays
      ;; 指定個数のオーバーレイを削除
      (while (< hw-cnt hiwin-overlay-count)
        ;; オーバーレイを削除
        (delete-overlay (nth hw-cnt hiwin-overlays))
        ;; カウンタアップ
        (setq hw-cnt (1+ hw-cnt))
        )
      ;; 初期化
      (setq hiwin-overlays nil)
      )
    ))

(defun hiwin-draw-ovl ()
  "一度すべてのオーバレイを削除しその後作成, そして描画する."
  (interactive)
  ;; すべてのオーバーレイを削除
  (hiwin-delete-ovl)
  ;; その後新たにオーバーレイを作成
  (hiwin-create-ovl)
  ;; 描画時にアクティブなウィンドウを記憶
  (setq hiwin-active-window (selected-window))
  (let (
        (hw-tgt-win nil)                ; 処理対象ウィンドウ
        (hw-win-lst (window-list))      ; ウィンドウリスト
        (hw-cnt 0)                      ; ループカウンタ
        (minibuffer-selected-window (minibuffer-selected-window))
        )
    (while hw-win-lst
      ;; 処理対象ウィンドウを取得
      (setq hw-tgt-win (car hw-win-lst))
      ;; 取得したウィンドウをウィンドウリストから削除
      (setq hw-win-lst (cdr hw-win-lst))
      ;; ミニバッファとアクティブ ウィンドウと
      ;; `hiwin-ignore-buffer-name-regexp'で指定されたbufferの
      ;; ウィンドウ以外を処理
      (unless (or (eq hw-tgt-win (minibuffer-window))
                  (eq hw-tgt-win hiwin-active-window)
                  (when hiwin-ignore-minibuffer-selected-window
                    (eq hw-tgt-win minibuffer-selected-window))
                  (string-match hiwin-ignore-buffer-name-regexp
                                (buffer-name (window-buffer hw-tgt-win))))
        (save-selected-window
          ;; 処理対象ウィンドウを選択
          (select-window hw-tgt-win t)
          ;; バッファ末尾の場合, ポイントを一文字戻す.  overlayの
          ;; after-stringで末尾に改行をたくさん挿入するとき, こうしな
          ;; いとポイントが遠くに飛ばされてしまう.
          (when (and (eq (point) (point-max))
                     (> (point-max) 1))
            ;; (unless buffer-read-only (insert " "))
            (backward-char 1)
            )
          ;; 処理対象ウィンドウにオーバーレイを設定
          (move-overlay (nth hw-cnt hiwin-overlays)
                        (point-min) (+ (buffer-size) 1) (current-buffer))
          (overlay-put (nth hw-cnt hiwin-overlays) 'window hw-tgt-win)
          (overlay-put (nth hw-cnt hiwin-overlays) 'priority 0)
          )
        ;; カウンタアップ
        (setq hw-cnt (1+ hw-cnt))
        ))
    ))

(defun hiwin-command-hook ()
  "オーバーレイを再描画する."
  (if executing-kbd-macro
      (input-pending-p)
    (condition-case hiwin-error
        (hiwin-draw-ovl)
      (error
       (if (not (window-minibuffer-p (selected-window)))
           (message "[%s] hiwin-mode catched error: %s"
                    (format-time-string "%H:%M:%S" (current-time))
                    hiwin-error))))))

;;;###autoload
(defun hiwin-refresh-ignore-buffer-names ()
  "正規表現`hiwin-ignore-buffer-name-regexp'を生成する.
`hiwin-ignore-buffer-names'から実際にハイライトの有無を判定する基準である,"
  (interactive)
  (setq hiwin-ignore-buffer-name-regexp
        (regexp-opt hiwin-ignore-buffer-names)))

;;;###autoload
(define-minor-mode hiwin-mode
  "Visible active window."
  :global t
  :lighter hiwin-mode-lighter
  :group 'hiwin
  (if hiwin-mode
      (progn
        (hiwin-refresh-ignore-buffer-names)
        (add-hook 'window-configuration-change-hook 'hiwin-command-hook))
    (remove-hook 'window-configuration-change-hook 'hiwin-command-hook)
    (hiwin-delete-ovl))
  )

;;;###autoload
(defun hiwin-activate ()
  "Turn on visible active window mode."
  (interactive)
  (hiwin-mode 1))

;;;###autoload
(defun hiwin-deactivate ()
  "Turn off visible active window mode."
  (interactive)
  (hiwin-mode -1))

;;;###autoload
(defun hiwin-version ()
  "Print `hiwin-version'."
  (interactive)
  (message "hiwin mode version %s" hiwin-version))

(provide 'hiwin)

;; Local Variables:
;; mode: emacs-lisp
;; coding: utf-8
;; End:

;;; hiwin.el ends here
