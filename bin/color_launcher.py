import tkinter as tk
import subprocess

# コマンド設定
COMMANDS = {
    'blue':   ['xterm', '-e', 'tcsh', '-c', 'echo 青色が押されました.; sleep 3'],
    'red':    ['xterm', '-e', 'tcsh', '-c', 'echo 赤色が押されました.; sleep 3'],
    'green':  ['xterm', '-e', 'tcsh', '-c', 'echo 緑色が押されました.; sleep 3'],
    'yellow': ['xterm', '-e', 'tcsh', '-c', 'echo 黄色が押されました.; sleep 3'],
}

def run_command(color):
    cmd = COMMANDS[color]
    subprocess.Popen(cmd)

root = tk.Tk()
root.title("カラーランチャー")
root.geometry("1050x300")

canvas = tk.Canvas(root, width=1050, height=300)
canvas.pack()

# 円の位置と色
buttons = [
    (150, 150, 'blue'),
    (400, 150, 'red'),
    (650, 150, 'green'),
    (900, 150, 'yellow'),
]

# 円を描画してイベントを設定
for x, y, color in buttons:
    r = 100
    item = canvas.create_oval(x-r, y-r, x+r, y+r, fill=color, outline="")
    canvas.tag_bind(item, "<Button-1>", lambda e, c=color: run_command(c))

root.mainloop()

