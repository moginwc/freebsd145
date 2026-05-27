#!/bin/tcsh
set STATE_FILE = "/tmp/volume_osd_value"

# 左チャネルの値をパーセントで取得
set vol_raw = `mixer vol.volume | awk -F"=" '{print $2}' | cut -d: -f1`
# 小数 -> 整数パーセント
set percent = `echo "$vol_raw * 100" | bc | awk '{printf "%d", $1}'`

# mute トグル処理
if ("$1" == "mute") then
    set mute_status = `mixer vol.mute | awk -F"=" '{print $2}'`
    if ("$mute_status" == "on") then
        echo "MUTE" > $STATE_FILE
    else
        # ミュート解除なら音量表示
        echo "$percent%" > $STATE_FILE
    endif
else
    # mute 以外は音量表示
    echo "$percent%" > $STATE_FILE
endif
