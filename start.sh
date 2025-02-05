#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt

URL="https://drive.usercontent.google.com/download?id=1_iE7rw2YXrM-yEL64NfWgxggzNo5HAAP&export=download&authuser=0&confirm=t&uuid=2e3f5d80-ebf2-45b3-86c3-36359123b7f2&at=AIrpjvOsCVliS5jie6aGtF5swjpx%3A1738730344270"

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
