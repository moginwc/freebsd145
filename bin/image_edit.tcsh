#!/bin/tcsh

set in_file = "/tmp/key-handler.tmp"
setenv out_dir $HOME

# メニュー表示
echo "=======================      "
echo "  画像処理メニュー           "
echo "=======================      "
echo "　１．200pxにリサイズ        "
echo "　２．320pxにリサイズ        "
echo "　３．480pxにリサイズ        "
echo "　４．左回転＋480pxにリサイズ"
echo "　５．右回転＋480pxにリサイズ"
echo "　６．640pxにリサイズ        "
echo "　Ｑ．終了                   "
echo "=======================      "
echo -n "番号を入力してください． "

# ユーザーの選択を読む
set choice = $<

# 選択肢が無効なら終了
if ("$choice" !~ [1-6] ) then
    exit 1
endif

# 画像編集処理
switch ("$choice")

    case "1":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -resize 200x200 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

    case "2":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -resize 320x320 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

    case "3":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -resize 480x480 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

    case "4":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -rotate -90 -resize 480x480 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

    case "5":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -rotate 90 -resize 480x480 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

    case "6":
        cat ${in_file} | xargs -I {} env out_dir=$out_dir tcsh -c 'set filename={}; \
            convert $filename -auto-orient -resize 640x640 -unsharp 0x1 -strip "$out_dir/${filename:t}"'
        breaksw

endsw

# 処理完了通知
\rm $in_file

echo ""
echo "$out_dir に作成されました．"
echo ""
echo -n "何かキーを押してください． "
set choice = $<

exit 0
