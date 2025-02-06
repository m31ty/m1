#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt


#combine_split_files.sh
set -e


#必要なツールのチェック
command -v jq >/dev/null 2>&1 || {
	echo "jq not found! Installing..."
	sudo apt install -y jq
}

#GitHub API設定
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${TAG_NAME}"
OUTPUT_FILE="poop.zip"

echo "=== リリース情報を取得しています ==="
release_info=$(curl -sH "Authorization: token ${GITHUB_TOKEN}" "${API_URL}")

echo "=== 分割ファイルをダウンロードしています ==="
echo "${release_info}" | jq -r '.assets[] | select(.name | startswith("poop.zip_part_")) | .browser_download_url' | sort -V | xargs -n1 wget -q --show-progress

echo "=== ファイルを結合しています ==="
if ls poop.zip_part_* 1> /dev/null 2>&1; then
	cat poop.zip_part_* > "${OUTPUT_FILE}"
	echo "結合完了: ${OUTPUT_FILE}"
	
	#整合性チェック(任意)
	echo "ファイルサイズチェック:"
	du -sh "${OUTPUT_FILE}"
else
	echo "分割ファイルが見つかりませんでした"
	exit 1
fi

echo "=== 分割ファイルを削除しています ==="
rm -v poop.zip_part_*
echo "ls start."
ls
echo "ls done."

unzip poop.zip

mkdir -p movies
cp -r poop/. movies/

# 不要なファイルを削除
rm -rf poop.zip poop
echo "delete file."
df -h --total

echo "Setup complete."
