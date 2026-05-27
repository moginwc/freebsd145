#!/bin/tcsh

# now_time: 現在の時刻
set now_time = `date "+%H:%M:%S"`
echo "現在の時刻: ${now_time}"

# ----------------------------
# 対話形式でパラメータ入力
# ----------------------------
echo -n "録音開始時刻 (HH:MM) を入力してください: "
set exec_time = $<

echo -n "録音分数 (分) を入力してください: "
set duration = $<

# ----------------------------
# 秒単位に変換して sleep
# ----------------------------
# target: 実行予定時刻のUNIX秒
# now: 現在のUNIX秒
set target = `date -j -f "%H:%M:%S" "${exec_time}:00" "+%s"`
set now    = `date "+%s"`

# 過去時刻なら翌日にずらす
if ($target <= $now) then
    @ target += 86400
endif

# 待機秒数
@ sleep_sec = $target - $now
echo "開始まで $sleep_sec 秒待機します..."
sleep $sleep_sec

# ----------------------------
# 録音実行
# ----------------------------
set now_time = `date "+%H:%M:%S"`
echo "録音開始: $now_time"
set filename = "rec_`date "+%Y%m%d_%H%M"`.mp4"

# 録音
ffmpeg \
  -f oss -i /dev/dsp0 \
  -f lavfi -i color=color=black:size=640x240 \
  -filter_complex "\
    [0:a]showwaves=s=640x120:mode=line:rate=25:colors=lime[wave]; \
    [1:v][wave]overlay=0:H/2, \
    drawtext=fontfile=/usr/local/share/fonts/ipa/ipag.otf: \
      text='%{localtime}':fontsize=32:fontcolor=white:x=48:y=48\
  " \
  -c:v libx264 -c:a aac \
  -t `expr $duration \* 60` \
  "$filename"

set now_time = `date "+%H:%M:%S"`
echo "録音終了: $now_time"
