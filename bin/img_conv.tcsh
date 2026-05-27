#!/bin/tcsh

# 画像をリサイズする。シャープネスにする。

set unsharp_opt = "1.5x1.0+0.1"
set out_dir = "~/work/Converted_Image_Files"
mkdir -p $out_dir

# オプションの意味(順番あり)
#   -auto-orient EXIF Orientation を見て回転・反転
#   -resize 縦横比を保ったまま縮小
#   -unsharp シャープ化
#   -strip 不要なメタデータを削除

foreach filename ($argv[2-$#argv])
    switch ("$argv[1]")
        case "200px":
            magick $filename -auto-orient -resize 200x200 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
        case "320px":
            magick $filename -auto-orient -resize 320x320 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
        case "480px":
            magick $filename -auto-orient -resize 480x480 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
        case "480px_rotate_left":
            magick $filename -auto-orient -rotate -90 -resize 480x480 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
        case "480px_rotate_right":
            magick $filename -auto-orient -rotate 90 -resize 480x480 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
        case "640px":
            magick $filename -auto-orient -resize 640x640 -unsharp $unsharp_opt -strip $out_dir/${filename:t}
            breaksw
    endsw
end

exit
