#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt


wget -O poop.zip "https://drive.usercontent.google.com/download?id=1_iE7rw2YXrM-yEL64NfWgxggzNo5HAAP&export=download&authuser=0&confirm=t&uuid=2e3f5d80-ebf2-45b3-86c3-36359123b7f2&at=AIrpjvOsCVliS5jie6aGtF5swjpx%3A1738730344270"
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
