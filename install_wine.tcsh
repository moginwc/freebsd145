#!/bin/tcsh

# wineのインストール
sudo pkg install -y wine wine-gecko wine-mono winetricks
yes | /usr/local/share/wine/pkg32.sh install wine mesa-dri
rehash # winetricksがインストールされたことを認識させる
winetricks corefonts
wineboot # 初回起動でWineシステムを初期化する

# 梅ゴシックのインストール
sudo pkg install -y ja-font-ume

# 共通の設定を行う
wineserver -w # wine関係のサーバープロセスをいったん終了する

# 共通の設定を行う - ウインドウの配色を設定する
sed -i '' 's/^"ActiveTitle"=.*/"ActiveTitle"="10 36 106"/'                 ~/.wine/user.reg
sed -i '' 's/^"GradientActiveTitle"=.*/"GradientActiveTitle"="166 202 240"/' ~/.wine/user.reg
sed -i '' 's/^"TitleText"=.*/"TitleText"="255 255 255"/'                    ~/.wine/user.reg

# 共通の設定を行う - タイトルバーの高さ・タイトルバーの左右グリップまたは横方向の余白を設定する
sed -i '' 's/^"CaptionHeight"=.*/"CaptionHeight"="-270"/'                   ~/.wine/user.reg
sed -i '' 's/^"CaptionWidth"=.*/"CaptionWidth"="-270"/'                     ~/.wine/user.reg

# 代替フォントの設定
sudo pkg install -y ja-nkf
nkf -W8 -w16L -Lw ./wine-japanese.reg.txt > ./wine-japanese.reg
regedit /s ./wine-japanese.reg

# 秀丸インストール(Wine10以降、サイレントインストールができなくなったので、
#   インストーラー形式のファイルを強制的に展開してProgram Files以下にファイルコピーをしています。よって関連付けなどが抜けます)
sudo pkg install -y cabextract # 秀丸のインストーラーの実態は.cabファイル
fetch https://hide.maruo.co.jp/software/bin/hm950_x64_signed.exe
if ( -f ./hm950_x64_signed.exe) then
    mkdir hidemaru
    cabextract -d ./hidemaru hm950_x64_signed.exe
    cp -r hidemaru ~/.wine/drive_c/Program\ Files/Hidemaru

    # 秀丸アイコンの抽出
    sudo pkg install -y icoutils
    mkdir hidemaru_icon
    wrestool -x --output=./hidemaru_icon -t14 ./hidemaru/Hidemaru.exe
    magick ./hidemaru_icon/Hidemaru.exe_14_102_1041.ico hidemaru.png
    cp hidemaru-0.png ~/icons/hidemaru.png

    # 秀丸の読み書き設定
    wineserver -w # wine関係のサーバープロセスをいったん終了する(下記./wine/user.regファイルに追記をしたいため)
    set addstr = '[Software\\Wine\\AppDefaults\\Hidemaru.exe]'
    grep -F -- "$addstr" ~/.wine/user.reg > /dev/null
    if ( $status != 0 ) then
        echo "$addstr" | tee -a ~/.wine/user.reg
        set addstr = '"Version"="winxp"'
        echo "$addstr" | tee -a ~/.wine/user.reg
    endif
endif

# WinMergeのサイレントインストール
fetch https://github.com/WinMerge/winmerge/releases/download/v2.16.42.1/WinMerge-2.16.42.1-x64-Setup.exe
if ( -f WinMerge-2.16.42.1-x64-Setup.exe ) then
    wine ./WinMerge-2.16.42.1-x64-Setup.exe /VERYSILENT # /VERYSILENTがサイレントインストールオプション
    # この後に何かフォルダーのようなものが表示されますが、閉じてください
endif

# BzEditor（ポータブルzip版）のインストール
fetch https://gitlab.com/-/project/12653927/uploads/da22779e33bcec39cbe8b6bddfacef4f/Bz1987Portable.zip
if ( -f Bz1987Portable.zip ) then
    unzip Bz1987Portable.zip
    mkdir ~/wine_bin
    cp -r Bz1987Portable ~/wine_bin/Bz
endif

# wine設定ファイルのコメント外し
sed -i '' 's/^#wine#//g' ~/.fvwm2rc
sed -i '' 's/^#wine#//g' ~/.cshrc
sed -i '' 's/^#wine#//g' ~/.xinitrc

# 8-24. フォントファイルの中身を閲覧したい
# 10-14. Wineで使えるいい感じの等幅フォントを生成したい
sudo pkg install -y fontforge
cd ./bin
tcsh ./create_font.tcsh
