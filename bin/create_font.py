import fontforge

# 元フォント
src_font_path = "/usr/local/share/fonts/ipa/ipag.otf"
font = fontforge.open(src_font_path)

# 新しいフォント作成（UnicodeFull）
newfont = fontforge.font()
newfont.encoding = "UnicodeFull"

# フォント名を設定

# ファミリ名
newfont.familyname = "My932ゴシック"
newfont.appendSFNTName('Japanese', 'Family', 'My932ゴシック')
newfont.appendSFNTName('English (US)', 'Family', 'My932Gothic')

# Fullname名
newfont.fullname = "My932ゴシック Regular"
newfont.appendSFNTName('Japanese', 'Fullname', 'My932ゴシック Regular')
newfont.appendSFNTName('English (US)', 'Fullname', 'My932Gothic Regular')

# PostScript名
newfont.fontname = "My932Gothic"

# 外部 CP932 Unicode 定義ファイルを読み込む
cp932_file = "create_font_unicode.txt"
with open(cp932_file, "r", encoding="utf-8") as f:
    cp932_list = [int(line.strip(), 16) for line in f if line.strip() and not line.startswith("#")]

# 抜き出し（例外処理付き）
for u in cp932_list:
    # 半角スペースは幅だけの空グリフを作成
    if u == 0x0020:
        if u not in newfont:
            newfont.createChar(u)
            newfont[u].width = 1024  # 半角幅に設定
        continue

    # U+2211 (Σ) は U+03A3 からコピー
    if u == 0x2211:
        if 0x03A3 in font:
            font.selection.none()
            font.selection.select(("unicode",), 0x03A3)
            font.copy()
            newfont.selection.none()
            newfont.selection.select(("unicode",), 0x2211)
            newfont.paste()
        else:
            print("Warning: U+03A3 not found, cannot copy for U+2211")
        continue

    # 通常コピー
    if u in font:
        font.selection.none()
        font.selection.select(("unicode",), u)
        font.copy()
        newfont.selection.none()
        newfont.selection.select(("unicode",), u)
        newfont.paste()
    else:
        print(f"Glyph U+{u:04X} not found in source font.")

# フォント情報をコピー
newfont.ascent = font.ascent
newfont.descent = font.descent
newfont.em = font.em

# 保存
output_path = "my932gothic.ttf" # ファイル名は全て小文字
newfont.generate(output_path)
print(f"抜き出し完了: {output_path}")
