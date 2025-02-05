#!/bin/bash


apt update && apt install -y ffmpeg
pip install -r requirements.txt

# ZIPファイルのダウンロードと展開処理
wget -O poop.zip https://drive.usercontent.google.com/download?id=1gcmz3wDf2WkEfD_eAmvGHz0o940E3RGJ&export=download&authuser=0&confirm=t&uuid=84e3c29d-0139-4728-8390-ee12c8e6d9a6&at=AIrpjvPxB0MFb13M_qTdgFK-CWki%3A1738727798019
unzip poop.zip

# poopディレクトリの中身をmoviesに移動
mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop

echo "Setup complete."
