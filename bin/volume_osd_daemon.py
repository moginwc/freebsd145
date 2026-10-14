#!/usr/bin/env python3.12
import tkinter as tk
import os, time, threading

STATE_FILE = "/tmp/volume_osd_value"
DISPLAY_DURATION_MS = 1500  # 表示時間（ミリ秒）

class VolumeHUD:
    def __init__(self, root):
        self.root = root
        self.root.overrideredirect(True)
        self.root.attributes("-topmost", True)
        self.root.geometry("200x200+583-136")  # 必要に応じて位置/サイズを変更

        self.canvas = tk.Canvas(root, width=200, height=200,
                                bg='#dedede', highlightthickness=0)
        self.canvas.pack()

        self.hide_job = None

        # 起動時は非表示
        self.root.withdraw()

        # ファイル監視スレッド開始
        threading.Thread(target=self.watcher, daemon=True).start()

    def watcher(self):
        last_mtime = 0
        while True:
            if os.path.exists(STATE_FILE):
                try:
                    mtime = os.path.getmtime(STATE_FILE)
                except OSError:
                    mtime = 0
                if mtime != last_mtime:
                    last_mtime = mtime
                    try:
                        with open(STATE_FILE, "r") as f:
                            val = f.read().strip()
                    except Exception:
                        val = ""
                    # メインスレッドで表示処理を呼ぶ
                    self.root.after(0, self.show, val)
            time.sleep(0.08)  # 監視間隔（短めにして連打に追従）

    def show(self, val):
        # 描画を更新
        self.canvas.delete("all")
        # アイコン（環境により絵文字は表示されないかも）
        self.canvas.create_text(100, 75, text="🔊", font=("Arial", 64), fill="#5f5f5f")
        # 音量テキスト
        display_text = val if val else ""
        self.canvas.create_text(100, 150, text=display_text, font=("Arial", 24), fill="#5f5f5f")

        # 表示（非表示状態なら復帰）
        try:
            self.root.deiconify()
            self.root.lift()
        except Exception:
            pass

        # 既存の非表示タイマーをキャンセルして再登録
        if self.hide_job:
            try:
                self.root.after_cancel(self.hide_job)
            except Exception:
                pass
            self.hide_job = None

        self.hide_job = self.root.after(DISPLAY_DURATION_MS, self.hide)

    def hide(self):
        try:
            self.root.withdraw()
        except Exception:
            pass
        self.hide_job = None


if __name__ == "__main__":
    root = tk.Tk()
    app = VolumeHUD(root)
    root.mainloop()
