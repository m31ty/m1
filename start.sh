#!/bin/bash

# 必要なパッケージのインストール
apt update && apt install -y ffmpeg
pip install -r requirements.txt

# poop.zip をダウンロード
wget -O poop.zip "https://drive.usercontent.google.com/download?id=1An7g4W538jGbeEuX8Vf1z-pU8UDMwS6Y&export=download&authuser=0&confirm=t&uuid=e1ab994f-79d4-43df-8a80-d32bb7c22991&at=AIrpjvOlBDqjncW5WAWODRK5xiNB%3A1738724788247"


# poop.zip を解凍
tmp_dir=$(mktemp -d)
unzip poop.zip -d "$tmp_dir"

# movies フォルダが存在しない場合は作成
mkdir -p movies

# poop フォルダの中身を movies に移動
mv "$tmp_dir/poop"/* movies/

# 一時ディレクトリの削除
rm -rf "$tmp_dir"
rm poop.zip

echo "Setup complete."
