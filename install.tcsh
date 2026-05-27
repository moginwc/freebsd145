#!/bin/tcsh

#-----------------------------------------
# FreeBSDカスタムインストーラー moginwc版
#-----------------------------------------

# メニューのパラメーターファイル
set paramfile = "/tmp/installer.$$"

# リポジトリ名
set ver = "freebsd144"

# インストール選択画面の表示
set selected = `dialog \
	--title "FreeBSD Custom Installer" \
    --stdout \
	--checklist "Select your options:" 14 76 6 \
	use_amdgpu "Use AMD GPU driver (Default: Intel GPU driver)" off \
	use_re0 "LAN interface: re0 (Default: em0)" off \
	use_jp_keyboard "Keyboard layout: 106 JP (Default: 101 US)" off \
	enable_numlock "Enable NumLock for X (Default: Off)" off \
	use_volume_keys "Use volume keys (Default: ALT+CTRL+↑,↓,M)" off \
    build_mlterm_uim "Build mlterm with uim (Default: pkg only)" off`

# システム起動時に ntpdが起動するよう設定する (3.初期設定 ntpd)
sudo service ntpd enable
sudo cp ./etc_ntp.conf /etc/ntp.conf

# 省エネ動作の設定を行う (3.初期設定 powerd)
sudo service powerd enable

# グラフィックドライバーのインストール (3.初期設定 グラフィックドライバー)
sudo pkg install -y -q drm-515-kmod
if (" ${selected:q} " =~ "* use_amdgpu *") then
	sudo sysrc kld_list+=amdgpu
else
	sudo sysrc kld_list+=i915kms
endif
sudo pw groupmod video -m pcuser

# ファイヤーウォールの設定 (3.初期設定 ファイヤーウォール)
sudo service pf enable
sudo sysrc pf_rules+=/etc/pf.conf
sudo cp etc_pf.conf /etc/pf.conf

if (" ${selected:q} " =~ "* use_re0 *") then
	sudo sed -i '' 's/ em0 / re0 /g' /etc/pf.conf
endif

# vimエディターをインストールする (3.初期設定 vimエディタ)
sudo pkg install -y -q vim
cp ./.vimrc ~
sed -i '' 's/^"//g' ~/.vimrc

# シェルスクリプト初期設定 (3.初期設定 シェルスクリプト)
cp ./.cshrc ~
cp ./.login ~
sed -i '' 's/^##//g' ~/.login

# X Window System をインストールする (3.初期設定 ウインドウ関係1)
sudo pkg install -y -q xorg

# ウィンドウマネージャをインストールする
mkdir -p ~/icons
cp ./third_party/programs.xpm ~/icons
sudo pkg install -y -q ImageMagick7
magick ~/icons/programs.xpm -trim +repage -scale 200% ~/icons/programs.png
sudo pkg install -y -q fvwm3
sudo pkg install -y -q ja-font-ipa

# ウィンドウシステムの初期設定 (3.初期設定 ウインドウ関係2,3)
cp ./.xinitrc ~
sed -i '' 's/^##//g' ~/.xinitrc
if (" ${selected:q} " =~ "* use_jp_keyboard *") then
	sed -i '' 's/^#106jp#//g' ~/.xinitrc
	sed -i '' 's/^xkbcomp /#xkbcomp /g' ~/.xinitrc
endif

cp ./.fvwm2rc ~
sed -i '' 's/^##//g' ~/.fvwm2rc

# 端末エミュレータのインストールと設定 (8-25. mltermを使いたい いったんpkg版をインストール)
sudo pkg install -y -q mlterm
cp -r ./.mlterm ~
cp ./third_party/xterm-sol.xpm ~/icons
magick ~/icons/xterm-sol.xpm -crop 44x34+5+2 ~/icons/xterm-sol.png

# (9-13.)GTK系アプリのデフォルトフォントを変更したい
cp ./.gtkrc-2.0 ~
mkdir -p ~/.config/gtk-3.0
cp ./.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/

# (9-14.)フォントのアンチエイリアスをグレースケール方式にしたい(GTK2系)
cp ./.Xresources ~

# 端末エミュレータのインストールと設定 (3.初期設定 端末エミュレータ 端末エミュレータの設定)
sudo pkg install -y -q xfce4-terminal
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
cp ./.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/

# 入力メソッド・日本語入力システムのインストールと設定 (3.初期設定 日本語入力1,2)
sudo pkg install -y -q ja-uim-anthy-unicode uim-gtk2 uim-gtk3 uim-qt5 uim-qt6
cp -r ./.xkb ~

# 入力メソッド・日本語入力システムの初期設定 (3.初期設定 日本語入力3相当)
cp -r ./.uim.d-anthy ~
mv ~/.uim.d-anthy ~/.uim.d

# ユーザー辞書ファイルの作成
mkdir -p ~/.anthy
## touch ~/.anthy/private_words_default
cp -r ./.anthy ~

# アプリのインストール (3.初期設定 Firefox、その他)
sudo pkg install -y -q firefox-esr
sudo pkg install -y -q scrot
sudo pkg install -y -q xlockmore
sudo pkg install -y -q lupe
sudo pkg install -y -q xpad3

# 8-3. Firefoxで、ダウンロードフォルダーを「~/Downloads」に変更したい
# 8-10. Firefoxの初期設定を、起動せずに行いたい
mkdir -p ~/Downloads
sudo mkdir -p /usr/local/lib/firefox/distribution
sudo cp ./policies.json /usr/local/lib/firefox/distribution

# 8-4. 付箋アプリ(Xpad)を使いたい
mkdir -p ~/.config/xpad
cp -r ./.config/xpad ~/.config

# 9-19. 音量調整時に、画面上に音量・ミュート状態を表示したい
mkdir -p ~/bin
cp ./bin/volume_osd_client.tcsh ~/bin/
cp ./bin/volume_osd_daemon.py ~/bin/
chmod +x ~/bin/volume_osd_client.tcsh
sudo pkg install -y -q webfonts

# 3.初期設定 (音量キー設定)
if (" ${selected:q} " =~ "* use_volume_keys *") then
	sed -i '' 's/^#volume_keys_true#//g' ~/.fvwm2rc
else
	sed -i '' 's/^#volume_keys_false#//g' ~/.fvwm2rc
endif

# 6-7.NumLockを効かせたい
if (" ${selected:q} " =~ "* enable_numlock *") then
	sudo pkg install -y -q numlockx
	sed -i '' 's/^#numlock#//g' ~/.xinitrc
endif

# 9-10.クリップボードの不具合を解決したい
sudo pkg install -y -q autocutsel

# 5-4.ログインした際のメッセージを、Last login以外、表示させない
sudo mv /etc/motd.template /etc/motd.template.old
sudo touch /etc/motd.template

# 8-2. ハングル文字や簡体字・繁体字、絵文字を表示させたい
sudo pkg install -y -q noto-sans-jp noto-emoji

# 8-6.chromium（ウェブブラウザ）を使用したい
sudo pkg install -y -q chromium webfonts
mkdir -p ~/Downloads
mkdir -p ~/.config/chromium/Default
cp -r ./.config/chromium/Default ~/.config/chromium/

# 9-1.デスクトップに、アプリを起動するランチャーを表示させたい
# 9-2.ランチャーに、システム負荷やバッテリー状態を表示させたい
cp /usr/local/lib/firefox/browser/chrome/icons/default/default32.png ~/icons/firefox.png
magick /usr/local/share/icons/hicolor/64x64/apps/chrome.png -resize 32x32 ~/icons/chrome.png
magick /usr/local/share/icons/hicolor/48x48/apps/org.xfce.terminal.png -crop 42x40+3+4 ~/icons/xfce4-terminal.png

sudo pkg install -y -q xload
sudo pkg install -y -q xbatt

# 8-15.システム情報を表示したい(conky設定)
sudo pkg install -y -q conky
cp ./.conkyrc ~
if (" ${selected:q} " =~ "* use_re0 *") then
	sed -i '' 's/ em0/ re0/g' ~/.conkyrc
endif

# 文字コード表
cp -r ./html ~

# 5-5.起動時のブートメニューやメッセージをできるだけ表示させない

# BIOSブート向け
sudo cp ./root_boot.config /boot.config

# UEFIブート向け
grep '^boot_mute=' /boot/loader.conf > /dev/null
if ( $status == 0 ) then
    sudo sed -i '' 's/^boot_mute=.*/boot_mute="YES"/' /boot/loader.conf
else
    echo 'boot_mute="YES"' | sudo tee -a /boot/loader.conf
endif
grep '^splash=' /boot/loader.conf > /dev/null
if ( $status == 0 ) then
    sudo sed -i '' 's/^splash=.*/splash="\/boot\/images\/freebsd-brand-rev.png"/' /boot/loader.conf
else
    echo 'splash="/boot/images/freebsd-brand-rev.png"' | sudo tee -a /boot/loader.conf
endif

# 共通
grep '^autoboot_delay=' /boot/loader.conf > /dev/null
if ( $status == 0 ) then
    sudo sed -i '' 's/^autoboot_delay=.*/autoboot_delay="-1"/' /boot/loader.conf
else
    echo 'autoboot_delay="-1"' | sudo tee -a /boot/loader.conf
endif

# 5-3.特定のコマンドは、パスワードなしでsudoを実行したい(visudoの設定)
set addstr = "pcuser ALL=NOPASSWD: /sbin/shutdown"
grep -F -- "$addstr" /usr/local/etc/sudoers > /dev/null
if ( $status != 0 ) then
    echo "$addstr" | sudo tee -a /usr/local/etc/sudoers
endif

# 5-6.IPアドレスを固定化したい(IPv4) *コメントアウト状態にて
set addstr = '#ifconfig_em0="inet 192.168.1.8/24"'
grep -F -- "$addstr" /etc/rc.conf > /dev/null
if ( $status != 0 ) then
    echo "$addstr" | sudo tee -a /etc/rc.conf
endif

set addstr = '#defaultrouter="192.168.1.1"'
grep -F -- "$addstr" /etc/rc.conf > /dev/null
if ( $status != 0 ) then
    echo "$addstr" | sudo tee -a /etc/rc.conf
endif

# 5-11.IPv6で接続したい *コメントアウト状態にて
set addstr = '#ifconfig_em0_ipv6="inet6 accept_rtadv"'
grep -F -- "$addstr" /etc/rc.conf > /dev/null
if ( $status != 0 ) then
    echo "$addstr" | sudo tee -a /etc/rc.conf
endif

# 6-6.スピーカーやイヤホン端子から音が出るようにしたい *コメントアウト状態にて
set addstr = '#hw.snd.default_unit=0'
grep -F -- "$addstr" /etc/rc.conf > /dev/null
if ( $status != 0 ) then
    echo "$addstr" | sudo tee -a /etc/sysctl.conf
endif

# 11-1.mozcのインストールと初期設定 (*ここでは初期設定のみでインストールはしない)
cp ./.uim.d-mozc/customs/custom-mozc.scm ~/.uim.d/customs/
mkdir ~/.mozc
/usr/local/bin/xxd -r -p ./.mozc/config1.db.hex > ~/.mozc/config1.db

# 8-14.サムネイル一覧から画像を選択して表示したい (nsxiv)
sudo pkg install -y -q nsxiv
mkdir -p ~/.config/nsxiv/exec
cp ./.config/nsxiv/exec/image-info ~/.config/nsxiv/exec/
cp ./.config/nsxiv/exec/key-handler ~/.config/nsxiv/exec/
chmod +x ~/.config/nsxiv/exec/image-info
chmod +x ~/.config/nsxiv/exec/key-handler
sudo pkg install -y -q p5-Image-ExifTool

# 8-26. 軽量画像ビュアnsxivをカスタマイズして使いたい
sudo pkg install -y -q gmake git
rehash # gmakeを認識させる
mkdir ~/work
pushd ~/work
git clone https://codeberg.org/nsxiv/nsxiv.git
pushd ./nsxiv

# nsxivバージョン34であることが前提
grep -Eq '^[[:space:]]*VERSION[[:space:]]*=[[:space:]]*34([[:space:]]|$)' ./config.mk
if ($status == 0) then
    cp ~/${ver}/nsxiv/config.def.h .
    cp ~/${ver}/nsxiv/config.mk .
    gmake CC=cc
    sudo gmake install
endif
popd
popd

# 端末エミュレータのインストールと設定 (8-25. mltermを使いたい コンパイル)
if (" ${selected:q} " =~ "* build_mlterm_uim *") then
    sudo git clone https://git.FreeBSD.org/ports.git /usr/ports
    cd /usr/ports
    sudo git checkout 2026Q1
    sudo mkdir -p /var/db/ports/x11_mlterm/
    sudo cp ~/${ver}/var_db_ports_x11_mlterm_options /var/db/ports/x11_mlterm/options 
    cd /usr/ports/x11/mlterm
    sudo env BATCH=yes make
    sudo env BATCH=yes make reinstall
    sed -i '' 's/^#mlterm#//g' ~/.fvwm2rc
    cd ~/${ver}
endif

# サンプル画像のコピー
mkdir ~/Pictures
magick ./colorbar1.svg ~/Pictures/colorbar1.png
magick ./colorbar2.svg ~/Pictures/colorbar2.png
magick ./colorbar3.svg ~/Pictures/colorbar3.png
magick ./colorbar4.svg ~/Pictures/colorbar4.png
cp /usr/local/share/doc/ImageMagick-7/images/mountains*.jpg ~/Pictures/

# 8-11.GIMPを使いたい
sudo pkg install -y -q gimp

# 8-17.QGIS(地理空間情報の閲覧、編集、分析)を使いたい
sudo pkg install -y -q qgis
cp line.csv point.csv ~

# 7-5.FreeBSDから、Windowsにリモートデスクトップ経由で接続したい
sudo pkg install -y -q freerdp

# 7-7.FreeBSDから、MacにVNC接続したい
sudo pkg install -y -q tigervnc-viewer

# 5-8.再起動時に/tmpフォルダーをクリアーしたい
sudo sysrc clear_tmp_enable="YES"

# 8-9.画面スライドショーしたい
sudo pkg install -y -q feh

# 13-12.自作のmanページを作成したい
cp -r ./man ~

# 8-23.ファイル管理ソフトThunarを使いたい、のインストールと設定ファイルのコピー
sudo pkg install -y -q thunar thunar-archive-plugin xarchiver

xdg-mime default userapp-vim-readonly.desktop text/plain
xdg-mime default userapp-feh.desktop image/png
xdg-mime default userapp-feh.desktop image/jpeg

mkdir -p ~/.local/share/applications
cp ./.local/share/applications/* ~/.local/share/applications

mkdir -p ~/.local/share/Thunar/sendto
cp ./.local/share/Thunar/sendto/* ~/.local/share/Thunar/sendto/

mkdir -p ~/.config/Thunar
cp ./.config/Thunar/uca.xml ~/.config/Thunar/
cp ./bin/img_conv.tcsh ~/bin/
chmod +x ~/bin/img_conv.tcsh
cp ./.config/gtk-3.0/bookmarks ~/.config/gtk-3.0/

mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
cp ./.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/

mkdir -p ~/.config/xarchiver
cp ./.config/xarchiver/xarchiverrc ~/.config/xarchiver/

# 8-23.(ファイルタイプ表示名の変更)
mkdir -p ~/.local/share/mime/packages
cp /usr/local/share/mime/packages/freedesktop.org.xml ~/.local/share/mime/packages
sed -i '' 's/平文テキストドキュメント/テキストファイル/g' ~/.local/share/mime/packages/freedesktop.org.xml
sed -i '' 's/平文文書/テキストファイル/g' ~/.local/share/mime/packages/freedesktop.org.xml
sed -i '' 's/目的符号文書/オブジェクトファイル/g' ~/.local/share/mime/packages/freedesktop.org.xml
update-mime-database ~/.local/share/mime

# 15-12.カラーピッカー付き拡大鏡アプリを作成したい
sudo pkg install -y -q py311-tkinter py311-pillow
cp ./bin/pixel_loupe.py ~/bin

# 7-3.Windowsやmacとファイル共有したい(SMB)
sudo pkg install -y -q samba416
sudo service samba_server enable
mkdir ~/share
sudo cp etc_smb4.conf /usr/local/etc/smb4.conf
sudo pdbedit -a -u pcuser
