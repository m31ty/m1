#!/bin/bash


apt update && apt install -y ffmpeg

pip install -r requirements.txt

# 必要な環境変数が設定されているか確認
if [ -z "$GITHUB_TOKEN" ] || [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
  echo "Error: GITHUB_TOKEN, REPO_OWNER, and REPO_NAME must be set."
  exit 1
fi

# ヘッダーを設定
HEADERS="-H \"Authorization: token $GITHUB_TOKEN\" -H \"Accept: application/vnd.github.v3+json\""
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed. Attempting to install..."
  if command -v apt >/dev/null 2>&1; then  # Debian/Ubuntu
    sudo apt update
    sudo apt install -y jq
  else
    echo "Error: Could not determine package manager to install jq."
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then # 再度確認
     echo "Error: Failed to install jq."
     exit 1
  fi
fi


# download_and_combine 関数を定義
download_and_combine() {
  tag_name="$1"
  base_filename="$2"

  echo "Processing files for tag: $tag_name, base filename: $base_filename"

  # リリースのURLを作成
  release_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/tags/$tag_name"

  # リリース情報を取得
  response=$(curl -s $HEADERS "$release_url")

  # エラーチェック (curl の終了コードが0でない場合)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch release information."
    echo "$response"
    exit 1
  fi

  # jq を使用して assets をパース
  assets=$(echo "$response" | jq '.assets')
  # パートファイルをフィルタリングしてソート
  parts=$(echo "$assets" | jq -c '.[] | select(.name | startswith("'${base_filename}_part_'"))' | sort -t_ -k3 -n)

  downloaded_files=""
  # 各パートをダウンロード
  for part in $(echo "$parts" |  while read -r line; do echo "$line"; done); do
    url=$(echo "$part" | jq -r '.browser_download_url')
    filename=$(echo "$part" | jq -r '.name')

    echo "Downloading $filename..."
    curl -s $HEADERS -L "$url" -o "$filename"
    if [ $? -ne 0 ]; then
      echo "Error: Failed to download $filename"
      exit 1
    fi

    downloaded_files="$downloaded_files $filename"
  done

  # ファイルを結合
  output_filename="$base_filename"
  > "$output_filename" #output_filename を空にする
  for part_file in $downloaded_files; do
    cat "$part_file" >> "$output_filename"
  done

  echo "Successfully combined files into $output_filename"

  # 一時ファイルを削除
  for part_file in $downloaded_files; do
    rm "$part_file"
  done
}


download_and_combine "v1.0" "poop.zip"
echo "DL poop.zip finished"
download_and_combine "v2.0" "comics.zip"
# download_and_combine "v3.0", "another_file.zip"


# ダウンロードしたファイルを解凍
unzip comics.zip
unzip -d movies poop.zip
# unzip -d comics Golgo.13.zip  # コメントアウトされたまま

# ファイルリストを表示 (解凍後)
echo "Files after unzip:"
ls

# 不要なファイルを削除
rm -rf poop.zip comics.zip #Golgo.13.zip  # Golgo.13.zip はコメントアウトされているので削除されない
echo "delete file."

# ディスク使用量を表示
df -h --total

echo "Setup complete."

# 最終的なファイルリストを表示
echo "Final file list:"
ls

exit 0
