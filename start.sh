#!/bin/bash


apt update && apt install -y ffmpeg

# ZIPファイルのダウンロードと展開処理
wget -O poop.zip "https://drive.usercontent.google.com/download?id=1An7g4W538jGbeEuX8Vf1z-pU8UDMwS6Y&export=download&authuser=0&confirm=t&uuid=e1ab994f-79d4-43df-8a80-d32bb7c22991&at=AIrpjvOlBDqjncW5WAWODRK5xiNB%3A1738724788247"
unzip poop.zip

# poopディレクトリの中身をmoviesに移動
mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop

pip install -r requirements.txt

echo "Setup complete."
