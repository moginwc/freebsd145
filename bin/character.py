import tkinter as tk
from PIL import Image, ImageTk  # Pillowライブラリが必要（pkg install py311-pillow）

class DotCharacterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("ドット絵キャラ移動")

        # Canvasのサイズ
        self.canvas_width = 448
        self.canvas_height = 576

        # Canvas作成
        self.canvas = tk.Canvas(root, width=self.canvas_width, height=self.canvas_height, bg="white")
        self.canvas.pack()

        # PNG画像読み込み（Pillow経由）
        self.image = Image.open("character.png")
        self.tk_image = ImageTk.PhotoImage(self.image)

        # 初期位置
        self.x = 100
        self.y = 100

        # 画像をCanvasに配置
        self.image_id = self.canvas.create_image(self.x, self.y, image=self.tk_image, anchor="nw")

        # キー入力バインド
        self.root.bind("<KeyPress>", self.on_key_press)

    def on_key_press(self, event):
        # 移動量（必要ならここで変更可能）
        dx, dy = 0, 0
        step = 8  # 移動ステップ（ピクセル単位）

        if event.keysym == "Up":
            dy = -step
        elif event.keysym == "Down":
            dy = step
        elif event.keysym == "Left":
            dx = -step
        elif event.keysym == "Right":
            dx = step

        self.x += dx
        self.y += dy

        # Canvas上で画像の位置を更新
        self.canvas.move(self.image_id, dx, dy)

if __name__ == "__main__":
    root = tk.Tk()
    app = DotCharacterApp(root)
    root.mainloop()

