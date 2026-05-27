# Python初期設定
import pyaudio
import numpy as np
import matplotlib.pyplot as plt
import time

CHUNK = 1024
running = True

# キーイベント処理
def on_key(event):
    global running
    if event.key in ['q', 'escape']:
        running = False

# PyAudio初期化
p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paInt16,
                channels=1,
                rate=44100,
                input=True,
                input_device_index=0,
                frames_per_buffer=CHUNK)

# matplotlib準備
plt.rcParams['toolbar'] = 'None'
plt.ion()
fig, ax = plt.subplots()
fig.canvas.manager.set_window_title('音声波形モニター')

# キーイベント登録
fig.canvas.mpl_connect('key_press_event', on_key)

# 波形の初期状態をオブジェクトとして作成する
x = np.arange(0, CHUNK)
line, = ax.plot(x, np.random.rand(CHUNK))

# グラフ表示設定
ax.set_xticks([])
ax.set_ylim(-32768, 32767)
ax.set_yticks(np.arange(-32768, 32768 + 1, 8192))

ax.tick_params(direction='in')

ax.axhline(16384, linestyle=(0, (2, 6)), linewidth=0.5, color='#bbbbbb')
ax.axhline(-16384, linestyle=(0, (2, 6)), linewidth=0.5, color='#bbbbbb')

# メインループ
while running and plt.fignum_exists(fig.number):
    try:
        # 音声データを読み込む
        data = stream.read(CHUNK)
    except OSError:
        break

    # 音声データから波形を描画する
    y = np.frombuffer(data, dtype=np.int16)
    line.set_ydata(y)
    fig.canvas.draw()

    fig.canvas.flush_events()
    time.sleep(0.016)

# 終了処理
stream.stop_stream()
stream.close()
p.terminate()
plt.close('all')
