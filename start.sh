#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt

python first.py
if [ $? -ne 0 ]; then
  echo "first.py の実行中にエラーが発生しました。スクリプトを終了します。"
  exit 1
fi

echo "DL complete."

unzip -d comics comics.zip
ls

unzip -d movies poop.zip

# 不要なファイルを削除
rm -rf poop.zip comics.zip
echo "delete file."
df -h --total

echo "Setup complete."
