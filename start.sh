#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt


wget -O poop.zip "https://uc279c65fa251cda0e9a9b21c90d.dl.dropboxusercontent.com/cd/0/get/CjgB5vXhZFZPDi6TPcqv_bPq0UHlVozuVXaqxUjyvNRy6_xJGsUBBFrMDyU4-W0VVsdzq9-zyFcKTiwd7s1BJJ9hoqt3PEnhu-wPfK7Xo9lcElKBfNuK9laxiBbuF4eeAd8-a37rE4Dp0TVg3tinAzQgd8CNZVEaSlDBIZziOkauFA/file?_download_id=3023850992775234462463448572417535957188091852228673603674103094&_log_download_success=1#"
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
