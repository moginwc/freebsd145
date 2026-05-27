import fontforge

# 元フォントを開く
font = fontforge.open("my932gothic.ttf")

# 存在するグリフの一覧と幅を取得
for glyph in font.glyphs():
    if glyph.unicode != -1:
        print(f"U+{glyph.unicode:04X} : width = {glyph.width}")
