# keyboard-layout

keyboard-layout.png の作成方法

- [Keyboard Layout Editor](http://www.keyboard-layout-editor.com/#/) にアクセス
- `Preset` - `ISO 60%` を選択
- `</> Raw data` に以下をコピペし `Download` - `Download PNG` を選択

``` json
["~\n`\n\n^Del","!\n1\n\nF1","@\n2\n\nF2","#\n3\n\nF3","$\n4\n\nF4","%\n5\n\nF5","^\n6\n\nF6","&\n7\n\nF7","*\n8\n\nF8","(\n9\n\nF9",")\n0\n\nF10","_\n-\n\nF11","+\n=\n\nF12","|\n¥","BS"],
[{w:1.5},"Tab","Q\n\n\nQuote","W","E\n\n\nEnd","R","T","Y","U","I","O","P\n\n\n↑","{\n[\n\nPgUp","}\n]\n\nPgDn",{x:0.25,w:1.25,h:2,w2:1.5,h2:1,x2:-0.25},"Enter"],
[{w:1.75},"Caps Lock\n英数","A\n\n\nHome","S","D\n\n\nDel","F\n\n\n→","G","H\n\n\nBS","J\n\n\nttt","K","L",":\n;\n\n^↑","\"\n'\n\n^↓","|\n\\"],
[{w:2.25},"Shift","Z","X","C","V","B\n\n\n←","N\n\n\n↓","M\n\n\nEnter","<\n,\n\n^Home",">\n.\n\n^End","?\n/","_\n\\",{w:1.75},"Shift"],
[{w:1.25},"Ctrl","Fn","Win","Alt",{c:"#90a0b0",w:1.25},"無変換",{c:"#cccccc",a:7,w:2.5},"",{c:"#a0b090",a:4,w:1.25},"変換",{c:"#cccccc"},"半角/全角","Menu","Ctrl"]
```

keyboard-layout-hhkb.png の作成方法

- `Preset` - `Default 60%` を選択
- `</> Raw data` に以下をコピペし `Download` - `Download PNG` を選択

``` json
["Esc","!\n1\n\nF1","@\n2\n\nF2","#\n3\n\nF3","$\n4\n\nF4","%\n5\n\nF5","^\n6\n\nF6","&\n7\n\nF7","*\n8\n\nF8","(\n9\n\nF9",")\n0\n\nF10","_\n-\n\nF11","+\n=\n\nF12","|\n\\","~\n`\n\n^Del"],
[{w:1.5},"Tab","Q\n\n\nQuote","W","E\n\n\nEnd","R","T","Y","U","I","O","P\n\n\n↑","{\n[\n\nPgUp","}\n]\n\nPgDn",{w:1.5},"BS"],
[{c:"#90a0b0",w:1.75},"Control",{c:"#cccccc"},"A\n\n\nHome","S","D\n\n\nDel","F\n\n\n→","G","H\n\n\nBS","J\n\n\nttt","K","L",":\n;\n\n^↑","\"\n'\n\n^↓",{w:2.25},"Enter"],
[{w:2.25},"Shift","Z","X","C","V","B\n\n\n←","N\n\n\n↓","M\n\n\nEnter","<\n,\n\n^Home",">\n.\n\n^End","?\n/",{w:1.75},"Shift","Fn"],
[{x:1.5},"Alt",{w:1.5},"◇",{a:7,w:6},"",{a:4,w:1.5},"◇",{c:"#a0b090"},"Ctrl"]
```
