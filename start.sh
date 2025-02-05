#!/bin/bash

# 更新と ffmpeg のインストール
echo "Updating package list and installing ffmpeg..."
apt update && apt install -y ffmpeg

URL="https://drive.usercontent.google.com/download?id=1An7g4W538jGbeEuX8Vf1z-pU8UDMwS6Y&export=download&authuser=0&confirm=t&uuid=e1ab994f-79d4-43df-8a80-d32bb7c22991&at=AIrpjvOlBDqjncW5WAWODRK5xiNB%3A1738724788247"
ZIP_FILE="poop.zip"
DEST_DIR="movies"

wget "$URL" -O "$ZIP_FILE"

# moviesフォルダがない場合は作成
mkdir -p "$DEST_DIR"

# zipを解凍（poopフォルダの中身のみをmoviesに移動）
unzip -o "$ZIP_FILE" -d "tmp_poop"
mv tmp_poop/poop/* "$DEST_DIR"/

# 一時フォルダとzipファイルを削除
rm -rf tmp_poop "$ZIP_FILE"

echo "展開完了: $DEST_DIR"

echo "Installing Python dependencies..."
pip install -r requirements.txt

echo "Setup complete."
