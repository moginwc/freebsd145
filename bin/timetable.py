#----------
# 初期設定
#----------

# python初期設定
import tkinter as tk
import tkinter.font as tkFont
from datetime import datetime, timedelta
import csv
import time
import threading

#------------------------
# 時刻表ファイル読み込み
#------------------------

# CSVファイルを読み込む
with open("/home/pcuser/bin/timetable.csv", encoding="utf-8") as f:
    reader = csv.reader(f)
    rows = list(reader)

title_text = rows[0][0]  # 見出し
schedule = []
for row in rows[1:]:
    dest, time_str = row
    hour, minute = map(int, time_str.strip().split(":"))
    schedule.append((dest.strip(), hour, minute))

# 翌日対応：時刻順に整列し、datetimeで保持
today = datetime.now().date()
schedule_dt = []
for dest, h, m in schedule:
    t = datetime.combine(today, datetime.min.time()) + timedelta(hours=h, minutes=m)
    if t < datetime.now():
        t += timedelta(days=1)
    schedule_dt.append((dest, t))

# ソート（念のため）
schedule_dt.sort(key=lambda x: x[1])

#----------
# 画面設定(1366x768モニター専用)
#----------

# ウインドウ回りの設定
root = tk.Tk()
root.title("発車案内")
root.geometry("1366x768")
root.configure(bg="black")
root.attributes("-fullscreen",True)
root.bind("<Escape>",lambda e: root.destroy()) # ESCキーで終了

canvas = tk.Canvas(root, bg="black", width=1366, height=768, highlightthickness=0)
canvas.pack()

# フォント設定
title_font  = tkFont.Font(family="IPAPGothic", size=48, weight="normal")
main_font   = tkFont.Font(family="IPAPGothic", size=112, weight="normal")
notice_font = tkFont.Font(family="IPAPGothic", size=96, weight="normal")

# 見出し、時刻、行き先、まもなく電車が来ますの表示部分の設定
title_id = canvas.create_rectangle(0, 0, 1366, 96, fill="gray")
title_text_id = canvas.create_text(683, 48, text=title_text, font=title_font, fill="white")

line1_time_id = canvas.create_text(320, 240, text="", font=main_font, fill="orange")
line1_dest_id = canvas.create_text(960, 240, text="", font=main_font, fill="lightgreen")

line2_time_id = canvas.create_text(320, 416, text="", font=main_font, fill="orange")
line2_dest_id = canvas.create_text(960, 416, text="", font=main_font, fill="lightgreen")

notice_id     = canvas.create_text(683, 608, text="", font=notice_font, fill="red")

# 現在表示中のインデックス
current_index = 0

#------------
# 発車票表示
#------------
def update_display():
    global current_index
    now = datetime.now()
    # 次の2件を取得
    next_trains = []
    i = current_index
    while len(next_trains) < 2:
        idx = i % len(schedule_dt)
        dest, t = schedule_dt[idx]
        if t > now:
            next_trains.append((dest, t))
        i += 1

    if len(next_trains) < 2:
        return

    # 表示を更新
    canvas.itemconfig(line1_time_id, text=next_trains[0][1].strftime("%H:%M"))
    canvas.itemconfig(line1_dest_id, text=next_trains[0][0])
    canvas.itemconfig(line2_time_id, text=next_trains[1][1].strftime("%H:%M"))
    canvas.itemconfig(line2_dest_id, text=next_trains[1][0])

    # 発車1分前チェック
    if 0 <= (next_trains[0][1] - now).total_seconds() <= 60:
        canvas.itemconfig(notice_id, text="まもなく電車が来ます")
    else:
        canvas.itemconfig(notice_id, text="")

    # 発車済みチェック
    if now >= next_trains[0][1]:
        current_index += 1

    root.after(1000, update_display)

# 最初の表示更新を呼び出す
update_display()

root.mainloop()
