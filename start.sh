#!/bin/bash

# 更新と ffmpeg のインストール
echo "Updating package list and installing ffmpeg..."
apt update && apt install -y ffmpeg

echo "Installing Python dependencies..."
pip install -r requirements.txt

echo "Setup complete."
