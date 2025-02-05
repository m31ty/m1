#!/bin/bash


apt update && apt install -y ffmpeg
pip install -r requirements.txt

# ZIPファイルのダウンロードと展開処理
wget -O poop.zip "https://drive.usercontent.google.com/download?id=1gcmz3wDf2WkEfD_eAmvGHz0o940E3RGJ&confirm=t&uuid=732ba3b9-38dd-47da-b8f3-b5a621eac06d&at=AIrpjvOOuxT2yvn6NDga3MD5Syjf%3A1738728329982"
unzip poop.zip

# poopディレクトリの中身をmoviesに移動
mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop

echo "Setup complete."
