#!/bin/tcsh

echo ""
echo "sudoのパスワードを入力してください."
sudo -v

while (1)
	echo ""
    echo "======================================="
    echo " ディスクユーティリティ (基本メニュー) "
    echo "======================================="
    echo " 1. 接続メディア一覧"
    echo " 2. パーティション構成"
    echo " 3. ディスク詳細情報"
    echo " Q. 終了"
	echo ""
    echo -n "選択してください [1-3,Q]: "
    set choice = $<

    switch ($choice)
        case 1:
            echo ""
            echo "--- 接続メディア一覧 ---"
            printf "\033[34m# camcontrol devlist\033[m\n"
            sudo camcontrol devlist
            breaksw

        case 2:
			echo ""
            echo -n "パーティション構成を表示するデバイスを入力 (例: da0): "
            set dev = $<
            if ("$dev" == "") then
				echo "" 
                echo "デバイス名が入力されませんでした."
            else if ( -e /dev/$dev ) then
				echo ""
                echo "--- パーティション構成 ($dev) ---"
				printf "\033[34m# gpart show $dev\033[m\n"
                sudo gpart show $dev
            else
                echo "デバイス /dev/$dev は存在しません."
            endif
			echo ""
            echo -n "続行するには何かキーを押してください . . ."
            $<
            breaksw

        case 3:
			echo ""
            echo -n "詳細情報を表示するデバイスを入力 (例: da0): "
            set dev = $<
            if ("$dev" == "") then
				echo "" 
                echo "デバイス名が入力されませんでした."
            else if ( -e /dev/$dev ) then
                if ( "$dev" =~ da* ) then
				    echo ""
                    echo "--- ディスク詳細情報 ($dev) ---"
    				printf "\033[34m# camcontrol inquiry $dev\033[m\n"
                    sudo camcontrol inquiry $dev
                else if ( "$dev" =~ ada* ) then
				    echo ""
                    echo "--- ディスク詳細情報 ($dev) ---"
    				printf "\033[34m# camcontrol identify $dev\033[m\n"
                    sudo camcontrol identify $dev
				else
					echo ""
                    echo "未対応デバイスです."
				endif
            else
                echo "デバイス /dev/$dev は存在しません."
            endif
			echo ""
            echo -n "続行するには何かキーを押してください . . ."
            $<
            breaksw

        case q:
            exit 0
            breaksw

        default:
			echo ""
            echo "無効な選択です。1-3またはQを入力してください."
            breaksw
    endsw
end
