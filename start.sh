#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt

python first.py
if [ $? -ne 0 ]; then
  echo "first.py の実行中にエラーが発生しました。スクリプトを終了します。"
  exit 1
fi

echo "DL complete."
ls
unzip poop.zip

# poopディレクトリの中身をmoviesに移動
mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop
echo "delete file."
df -h --total

echo "Setup complete."
