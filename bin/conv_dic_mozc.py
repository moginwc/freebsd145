import plistlib

# ユーザー辞書を読み込む
with open('ユーザ辞書.plist', 'rb') as f:
    plist_data = plistlib.load(f)

# よみがなと単語を抽出し、標準出力に表示する
for item in plist_data:
    reading = item.get("shortcut", "")
    word = item.get("phrase", "")
    # 整形して出力する
    print(f'{reading}\t{word}\t名詞')
