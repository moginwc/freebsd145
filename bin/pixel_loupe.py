#!/usr/bin/env python3
import tkinter as tk
from PIL import ImageGrab, Image, ImageTk

class ColorMeter:
    def __init__(self, root):
        self.root = root
        root.title("拡大鏡 - Pixel Loupe")
        root.geometry("412x244")
        root.resizable(False, False)
        root.configure(bg="#f6f6f6")

        # 左側：拡大ビュー Canvas
        self.zoom_factor = 12
        self.canvas = tk.Canvas(root, width=self.zoom_factor*17, height=self.zoom_factor*17, bg="white")
        self.canvas.place(x=16, y=16)


        # 中央マーカーサイズ
        self.marker_size = self.zoom_factor / 2

        # 右側：色表示フレーム
        self.color_display = tk.Label(root, bg="#fff", bd=0)
        self.color_display.place(x=236, y=16+1, width=160, height=48)

        # 表示形式選択ラジオボタン
        self.format_var = tk.StringVar(value="#FFFFFF")
        formats = ["#FFFFFF", "(255,255,255)", "1.00 1.00 1.00"]
        y_offset = 80
        for fmt in formats:
            rb = tk.Radiobutton(
                root,
                text=fmt,
                font=("IPAPGothic", 10),
                bg="#f6f6f6",
                activebackground="#f6f6f6",
                highlightthickness=0,
                variable=self.format_var,
                value=fmt,
                command=self.update_display
            )
            rb.place(x=236, y=y_offset)
            y_offset += 24

        # 色値表示ラベル
        self.value_label = tk.Label(root, text="", font=("IPAGothic", 16), anchor="center", bg="#ffffff", bd=1, relief="solid")
        self.value_label.place(x=236, y=192, width=160)

        # コメント
        self.memo_label = tk.Label(root, text="Ctrl+Shift+C：カラー値コピー", font=("IPAPGothic", 8), bg="#f6f6f6", anchor="e")
        self.memo_label.place(x=16, y=226, width=412-16-16)

        # キーイベント
        root.bind("<Control-Shift-C>", self.copy_to_clipboard)
        root.bind("<q>", self.quit_app)
        root.bind("<Escape>", self.quit_app)

        # 現在の色
        self.current_color = (255, 255, 255)

        # マウス追跡
        root.after(50, self.update_color)

    def update_color(self):
        x, y = self.root.winfo_pointerxy()
        screen = ImageGrab.grab(bbox=(x-8, y-8, x+9, y+9))  # 17x17
        self.current_color = screen.getpixel((8, 8))  # 中央ピクセル

        self.show_zoom(screen)
        self.update_display()
        self.root.after(50, self.update_color)

    def show_zoom(self, img):
        zoomed = img.resize((17*self.zoom_factor, 17*self.zoom_factor), Image.NEAREST)
        self.tkimage = ImageTk.PhotoImage(zoomed)
        self.canvas.delete("all")  # 前の描画を消す
        self.canvas.create_image(0, 0, anchor="nw", image=self.tkimage)

        # 正確に中央マーカーを描画
        center = 8.5 * self.zoom_factor  # 中央ピクセル
        self.canvas.create_rectangle(
            center - self.marker_size,
            center - self.marker_size,
            center + self.marker_size,
            center + self.marker_size,
            outline="red",
            width=2
        )

    def update_display(self):
        r, g, b = self.current_color
        fmt = self.format_var.get()
        if fmt == "#FFFFFF":
            val = f"#{r:02X}{g:02X}{b:02X}"
        elif fmt == "(255,255,255)":
            val = f"({r},{g},{b})"
        else:
            val = f"{r/255:.2f} {g/255:.2f} {b/255:.2f}"
        self.value_label.config(text=val)
        self.color_display.config(bg=f"#{r:02X}{g:02X}{b:02X}")

    def copy_to_clipboard(self, event=None):
        self.root.clipboard_clear()
        self.root.clipboard_append(self.value_label.cget("text"))
        print(f"Copied: {self.value_label.cget('text')}")

    def quit_app(self, event=None):
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = ColorMeter(root)
    root.mainloop()
