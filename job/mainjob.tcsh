#!/bin/tcsh -f

if ("$1" != "start" ) then
    echo "This shell script must not be executed from the command line."
    exit 1
endif

set dt = `date '+%Y-%m-%d %H:%M:%S'`
echo "main job start. ${dt}"

# 実処理
sleep 10

if ($status != 0) then
    # 異常終了
    touch /home/pcuser/job/mainjob.abn
    set dt = `date '+%Y-%m-%d %H:%M:%S'`
    echo "main job abnormal end. ${dt}"
    exit 1
else
    # 前処理終了ファイルを消す
    rm -f /home/pcuser/job/frontjob.end

    # 正常終了
    touch /home/pcuser/job/mainjob.end
    set dt = `date '+%Y-%m-%d %H:%M:%S'`
    echo "main job end. ${dt}"
    exit 0
endif
