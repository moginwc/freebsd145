import pynmea2
import csv
from datetime import datetime, time, timedelta

# 入力NMEAファイルと出力CSVファイルの指定
input_file = "gps_data.nmea"
output_file = "gps_data.csv"

# JST (UTC+9) のオフセット
JST_OFFSET = timedelta(hours=9)

# CR+LFではなくLFを明示的に使用
with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    writer = csv.writer(outfile, lineterminator="\n")  # LFを指定
    writer.writerow(["Latitude", "Longitude", "Timestamp (JST)"])  # ヘッダー行

    for line in infile:
        try:
            # NMEA文を解析
            msg = pynmea2.parse(line)

            # RMC文のみを処理
            if isinstance(msg, pynmea2.RMC):
                # タイムスタンプをJSTに変換
                if msg.datestamp and msg.timestamp:
                    # msg.timestampをdatetime.timeに変換
                    timestamp_time = time(
                        hour=msg.timestamp.hour,
                        minute=msg.timestamp.minute,
                        second=msg.timestamp.second,
                    )
                    # UTCでの日時を計算
                    utc_datetime = datetime.combine(msg.datestamp, timestamp_time)
                    # JSTに変換
                    jst_datetime = utc_datetime + JST_OFFSET
                    # JSTタイムスタンプをフォーマット
                    timestamp = jst_datetime.strftime("%Y-%m-%d %H:%M:%S")
                else:
                    timestamp = "N/A"  # 日付や時刻がない場合

                # 緯度、経度、JSTタイムスタンプを書き込み
                writer.writerow([msg.latitude, msg.longitude, timestamp])

        except pynmea2.ParseError:
            continue  # 無効な行をスキップ
        except AttributeError:
            # タイムスタンプが欠けている場合もスキップ
            continue
