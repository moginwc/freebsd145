import tkinter as tk
import subprocess

#-------------------------------
# 画面設定
#-------------------------------
WIDTH = 640
HEIGHT = 360
ITEM_HEIGHT = 34
START_Y = 48

WHITE = "#ecf3f3"
BLACK = "#3b4921"

#-------------------------------
# メニュー項目（名前, コマンド） ※16項目固定
#-------------------------------
MENU = [
    ("端末エミュレータ 80x24",  "xfce4-terminal --title=端末エミュレータ"),
    ("端末エミュレータ 132x24", "xfce4-terminal --geometry=132x24 --title=端末エミュレータ"),
    ("ファイルマネージャ", "thunar"),
    ("カレンダー", "xterm -geometry 70x38 -T カレンダ -e tcsh -c 'cal -y; bash read -n 1'"),
    ("メールツール", "chrome --no-default-browser-check https://mail.google.com/mail/"),
    ("時計", "xclock -name 時計"),
    ("電卓", "xcalc"),
    ("パフォーマンスメータ", "xterm -e top"),
    ("付箋", "xpad -s"),
    ("ウェブブラウザ Firefox", "firefox"),
    ("ウェブブラウザ Chromium", "chrome --no-default-browser-check"),
    ("", ""),
    ("", ""),
    ("", ""),
    ("", ""),
    ("メニューの終了", "exit"),
]

#-------------------------------
# tkinter ウィンドウ初期化
#-------------------------------
root = tk.Tk()
root.title("アプリケーション起動メニュー")
root.geometry(f"{WIDTH}x{HEIGHT}")
root.configure(bg=WHITE)
canvas = tk.Canvas(root, width=WIDTH, height=HEIGHT, bg=WHITE, highlightthickness=0)
canvas.pack()

#-------------------------------
# 背景描画
#-------------------------------

# 黒色の外枠
canvas.create_rectangle( 0, 0, 640, 360, fill=BLACK, outline="")

# 4x4パターン画像を作る
tile = 4
tile_img = tk.PhotoImage(width=tile, height=tile)
data = [
    [BLACK, WHITE, WHITE, WHITE],
    [WHITE, WHITE, WHITE, WHITE],
    [WHITE, WHITE, BLACK, WHITE],
    [WHITE, WHITE, WHITE, WHITE],
]

for y in range(tile):
    for x in range(tile):
        tile_img.put(data[y][x], (x, y))

# 画面にタイル敷き詰め
for y in range(16, 344, tile):
    for x in range(2, WIDTH-6, tile):
        canvas.create_image(x, y, image=tile_img, anchor="nw")

# 画像が消えないよう保持
canvas.tile_img = tile_img

#-------------------------------
# メニュー描画
#-------------------------------
items = []       # (x1,y1,x2,y2,rect_id,text_id,cmd)
menu_rects = []  # (rect_id, original_fill)
current_hover = None

# 1pxディザ
def draw_dither(canvas, x1, y1, x2, y2, c1, c2):

    for y in range(y1, y2):
        for x in range(x1, x2):
            if (x + y) % 2 == 0:
                color = c1
            else:
                color = c2

            canvas.create_rectangle(
                x, y, x+1, y+1,
                outline="",
                fill=color
            )

# メニュー矩形描画
for i, (name, cmd) in enumerate(MENU):

    if i < 8:
        y1 = START_Y + i*ITEM_HEIGHT
        y2 = y1 + 24
        x1 = 40
        x2 = x1 + 16 * 16
    else:
        y1 = START_Y + (i-8)*ITEM_HEIGHT
        y2 = y1 + 24
        x1 = 340
        x2 = x1 + 16 * 16

    if name != "":

        # 影の部分を描画する
        canvas.create_rectangle(x1+2, y1+2, x2+2, y2+2, fill=BLACK, width=0)

        # 枠全体を1pxごとに塗りつぶす
        draw_dither(canvas, x1, y1, x2, y2, WHITE, BLACK)

        # 内側を塗りつぶす
        rect_id = canvas.create_rectangle(x1+4, y1+4, x2-4, y2-4, fill=WHITE, width=0)

        # テキストメニューの設定
        text_id = canvas.create_text( x1+4, (y1+y2)//2-1, text=name, fill=BLACK, font=("IPAGothic", 12), anchor="w")

        items.append((x1, y1, x2, y2, rect_id, text_id, cmd))

#-------------------------------
# コマンド実行関数
#-------------------------------
def run_command(cmd):
    if cmd == "exit":
        root.destroy()
    else:
        subprocess.Popen(cmd, shell=True)

#-------------------------------
# マウスクリック
#-------------------------------
def click(event):
    for (x1, y1, x2, y2, rect_id, text_id, cmd) in items:
        if x1 <= event.x <= x2 and y1 <= event.y <= y2:

            canvas.itemconfig(rect_id, fill=WHITE)
            canvas.itemconfig(text_id, fill=BLACK)

            def restore_color():
                canvas.itemconfig(rect_id, fill=BLACK)
                canvas.itemconfig(text_id, fill=WHITE)

            canvas.after(120, restore_color)

            run_command(cmd)
            break

canvas.bind("<Button-1>", click)

#-------------------------------
# マウスオーバーでハイライト
#-------------------------------
def on_motion(event):
    global current_hover

    new_hover = None

    for i, (x1, y1, x2, y2, rect_id, text_id, cmd) in enumerate(items):
        if x1 <= event.x <= x2 and y1 <= event.y <= y2:
            new_hover = i
            break

    # 変化がなければ何もしない
    if new_hover == current_hover:
        return

    # 前のハイライト解除
    if current_hover is not None:
        x1, y1, x2, y2, rect_id, text_id, cmd = items[current_hover]
        canvas.itemconfig(rect_id, fill=WHITE)
        canvas.itemconfig(text_id, fill=BLACK)

    # 新しいハイライト
    if new_hover is not None:
        x1, y1, x2, y2, rect_id, text_id, cmd = items[new_hover]
        canvas.itemconfig(rect_id, fill=BLACK)
        canvas.itemconfig(text_id, fill=WHITE)

    current_hover = new_hover

canvas.bind("<Motion>", on_motion)

#-------------------------------
# ESC または Q で終了
#-------------------------------
def quit_app(event):
    root.destroy()

root.bind("<Escape>", quit_app)
root.bind("<q>", quit_app)
root.bind("<Q>", quit_app)

#-------------------------------
# メインループ
#-------------------------------
root.mainloop()

#-------------------------------
# 参考
#-------------------------------

# 画面は、初代DynaBook付属のDOS版DynaBookメニューを参考にしました。
# 配色は、DOSVAXJ3を参考にしました。
