#!/bin/bash


apt update && apt install -y ffmpeg
pip install -r requirements.txt

# ZIPファイルのダウンロードと展開処理
wget -O poop.zip 
unzip poop.zip

# poopディレクトリの中身をmoviesに移動
mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop

echo "Setup complete."
