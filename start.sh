#!/bin/bash

# 更新と ffmpeg のインストール
echo "Updating package list and installing ffmpeg..."
apt update && apt install -y ffmpeg

URL="https://drive.usercontent.google.com/download?id=1B98LCiSeoZ110xXSJV6NQgCxRRkyxMcT&confirm=t&uuid=2672de09-a828-43f6-a48c-fb0b1b84377a&at=AIrpjvNNqQWTPAFgLSSkNxbur2Nr%3A1738721222351"
ZIP_FILE="poop.zip"
DEST_DIR="movies"

mkdir -p "$DEST_DIR"
wget -O "$ZIP_FILE" "$URL"
if [ $? -eq 0 ]; then
    echo "Download successful: $ZIP_FILE"

    # ZIPファイルを展開
    unzip "$ZIP_FILE" -d "$DEST_DIR"

    # 展開が成功したらZIPファイルを削除
    if [ $? -eq 0 ]; then
        echo "Extraction successful: $DEST_DIR"
        rm "$ZIP_FILE"
    else
        echo "Extraction failed!"
    fi
else
    echo "Download failed!"
fi

echo "Installing Python dependencies..."
pip install -r requirements.txt

echo "Setup complete."
