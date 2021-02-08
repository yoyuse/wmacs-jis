# wmacs-jis

Windows/Emacs compromise key bindings for JIS keyboard.

![wmacs](img/keyboard-layout.png)

## wmacs.ahk

wmacs は、JIS キーボード用に作られた Windows 向けのキー配列です。
[AutoHotkey](https://www.autohotkey.com/) で実装されています。

wmacs 配列は、JIS キーボード上に US 配列を実現するとともに、 `無変換` キーを修飾キーとして使い、Windows の標準的なショートカットキー (カット&ペーストやアンドゥなど) と Emacs の基本的なキーバインド (カーソル移動や削除など) を折衷し、`無変換-`*key* に割り当てています。

## wmacs キーバインド

### Emacs 風パート

| キー | 意味 | 備考 |
|----|----|----|
| `無変換-a`/`e` | `Home`/`End` | 行頭/行末 |
| `無変換-b`/`f`/`n`/`p` | `←`/`→`/`↓`/`↑` | カーソル移動 |
| `無変換-d` | `Del` | 削除 |
| `無変換-h` | `BS` | バックスペース |
| `無変換-m` | `Enter` | 改行 |
| `無変換-q` | quoted-insert | `無変換-q 無変換-f` で `C-f` など |

### Windows 風パート

| キー | 意味 | 備考 |
|----|----|----|
| `無変換-c` | `C-c` | コピー |
| `無変換-s` | `C-s` | 保存 |
| `無変換-v` | `C-v` | 貼り付け |
| `無変換-x` | `C-x` | カット |
| `無変換-y` | `C-y` | リドゥ |
| `無変換-z` | `C-z` | アンドゥ |

### その他パート

| キー | 意味 | 備考 |
|----|----|----|
| `無変換-1`～`9`/`0`/`-`/`=` | `F1`～`F9`/`F10`/`F11`/`F12` | ファンクションキー |
| `無変換-[`/`]` | `PdUp`/`PgDn` | 前/次ページ |
| `無変換-,`/`.` | `C-Home`/`C-End` | 文書の先頭/末尾 |
| `無変換-;`/`'` | `C-↑`/`↓` | 行スクロールダウン/アップ |
| `S-無変換-;` | 日付入力 | *YYYY-mm-dd* 形式 |
| `S-無変換-'` | 日付入力 | *yymmdd* 形式 |
| `無変換-j` | [ttt](https://github.com/yoyuse/ttt) 変換 | TT-code 日本語入力 |
| `無変換-Esc` | reload | wmacs.ahk の再読み込み |
| `無変換-`*key* | `C-`*key* | その他の文字キー |
| `カタカナひらがな` | `半角/全角` | IME のトグル |

### `C-q`

wmacs の `無変換-`*key* は、実際は `LCtrl+`*key* として定義したものの一部を Emacs キーバインドなどで上書きしています。
`無変換-q` (quoted-insert) は、その上書きされたキーを入力するものです。

たとえば、`Ctrl+F` (検索) は `無変換-q 無変換-f` で、`Ctrl+N` (新規作成) は `無変換-q 無変換-n` で入力できます。

### `RCtrl`

右 Ctrl キー (`RCtrl`) も wmacs バインドの影響を受けず、そのまま入力されます。
wmacs では `RCtrl` として `変換-` が割り当てられています。
`Ctrl+F` は `変換-f` で、`Ctrl+N` は `変換-n` でも入力できます。

## HHKB (英語配列) で wmacs を使う

![wmacs](img/keyboard-layout-hhkb.png)

wmacs は HHKB 英語配列で使うこともできます。
HHKB 英語配列には `無変換` (`LCtrl`) も `変換` (`RCtrl`) もありませんが、`LCtrl` については、打鍵しやすい位置にある `Control` を使えばよいでしょう。
`RCtrl` については、 wmacs のメニューの `Remap RAlt to RCtrl` にチェックを入れると、 `RAlt` が `RCtrl` として使えるようになります。

wmacs は、日本語キーボードドライバで使用する想定でキーをリマップしています。
HHKB を英語キーボードドライバで使用していて、キー配置がずれる場合は、 wmacs のメニューの `Use 104 Keyboard Driver` をチェックしてみてください。
