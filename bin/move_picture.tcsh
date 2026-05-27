#!/bin/tcsh

# 保存先のディレクトリを設定する
set base_dir="$HOME/Pictures"

# ファイル名が指定されていない場合は終了する
if ($#argv == 0) then
    echo "ファイルを指定してください。"
    exit 1
endif

# 各ファイルを処理
foreach file ($argv)
    # JPEGまたはPNGファイルのみ処理
    if (! -f "$file" || ("$file:e" != "jpg" && "$file:e" != "jpeg" && "$file:e" != "png" && "$file:e" != "JPG" && "$file:e" != "JPEG" && "$file:e" != "PNG")) then
        echo "$file は JPEG/PNG ファイルではありません。"
        continue
    endif

    # 作成日時を取得する
    set date_str=`exiftool -DateTimeOriginal -d "%Y/%m/%d" -s3 "$file"`
    if ("$date_str" == "") then
        echo "$file のタイムスタンプが見つかりません。"
        continue
    endif

    # 年・月・日に分離する
    set year=`echo $date_str | cut -d'/' -f1`
    set month=`echo $date_str | cut -d'/' -f2`
    set day=`echo $date_str | cut -d'/' -f3`

    # 移動先ディレクトリを作成する
    set target_dir="$base_dir/$year/$month/$day"
    if (! -d "$target_dir") mkdir -p "$target_dir"

    # 移動先ファイル名を設定する
    set filename=`basename "$file"`
    set target_file="$target_dir/$filename"

    # ファイル名が重複する場合、連番を追加する
    set count = 1
    while (-e "$target_file")
        set target_file = "$target_dir/${filename:r}_$count.$filename:e"
        @ count++
    end

    # ファイルを移動する
    mv "$file" "$target_file"

    # 移動したファイルのパーミッションを読み取り専用に設定する
    chmod 440 "$target_file"
end
