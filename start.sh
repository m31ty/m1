#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt

URL="https://drive.usercontent.google.com/download?id=1gcmz3wDf2WkEfD_eAmvGHz0o940E3RGJ&confirm=t&uuid=732ba3b9-38dd-47da-b8f3-b5a621eac06d&at=AIrpjvOOuxT2yvn6NDga3MD5Syjf%3A1738728329982"

# 保存先のファイル名
ZIP_FILE="poop.zip"

# 展開先のフォルダ
DEST_DIR="movies"

# zipをダウンロード
wget "$URL" -O "$ZIP_FILE"
echo "DL complete."

# moviesフォルダがない場合は作成
mkdir -p "$DEST_DIR"

# zipを解凍（poopフォルダの中身のみをmoviesに移動）
unzip -o "$ZIP_FILE" -d "tmp_poop"
mv tmp_poop/poop/* "$DEST_DIR"/
echo "unzip complete."

# 一時フォルダとzipファイルを削除
rm -rf tmp_poop "$ZIP_FILE"
echo "delete file."
df -h --total

echo "Setup complete."
