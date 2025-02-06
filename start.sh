#!/bin/bash

# combine_split_files_with_logging.sh
set -eo pipefail

# ログ出力関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 環境変数チェック
required_vars=(
    GITHUB_TOKEN
    REPO_OWNER
    REPO_NAME
    TAG_NAME
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "ERROR: 環境変数 $var が設定されていません"
        exit 1
    fi
done

# 一時ディレクトリ作成
TMP_DIR="download_tmp_$(date +%s)"
mkdir -p "${TMP_DIR}"
log "一時ディレクトリ作成: ${TMP_DIR}"

# 依存関係チェック
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        log "ERROR: $1 が見つかりません"
        exit 1
    fi
}

log "=== 依存関係チェック開始 ==="
check_dependency curl
check_dependency jq
check_dependency wget
check_dependency sort
log "=== 依存関係チェック完了 ==="

# GitHub API設定
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${TAG_NAME}"
OUTPUT_FILE="poop.zip"

# リリース情報取得
log "=== リリース情報取得開始 ==="
release_info=$(curl -sfL \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${API_URL}") || {
    log "ERROR: リリース情報の取得に失敗しました"
    exit 1
}
log "リリース情報取得成功: ${API_URL}"

# 分割ファイルURL抽出
log "=== 分割ファイルURL抽出開始 ==="
part_urls=$(echo "${release_info}" | jq -r '.assets[] | select(.name | startswith("poop.zip_part_")) | .browser_download_url' | sort -V) || {
    log "ERROR: ファイルURLの抽出に失敗しました"
    exit 1
}

file_count=$(echo "${part_urls}" | wc -l)
log "検出された分割ファイル数: ${file_count}"

if [ "${file_count}" -eq 0 ]; then
    log "ERROR: 分割ファイルが見つかりませんでした"
    exit 1
fi

# ファイルダウンロード
log "=== ファイルダウンロード開始 ==="
echo "${part_urls}" | xargs -n1 -P4 -I{} wget -q --show-progress -P "${TMP_DIR}" {} || {
    log "ERROR: ダウンロードに失敗しました"
    exit 1
}

downloaded_files=$(ls -1 "${TMP_DIR}"/poop.zip_part_* | sort -V)
log "ダウンロード完了ファイル数: $(echo "${downloaded_files}" | wc -l)"

# ファイル結合
log "=== ファイル結合処理開始 ==="
combined_size=0
for f in ${downloaded_files}; do
    file_size=$(du -b "${f}" | cut -f1)
    combined_size=$((combined_size + file_size))
done

log "結合前総ファイルサイズ: ${combined_size} bytes"
log "出力ファイル名: ${OUTPUT_FILE}"

cat "${TMP_DIR}"/poop.zip_part_* > "${OUTPUT_FILE}" || {
    log "ERROR: ファイル結合に失敗しました"
    exit 1
}

# 結果検証
log "=== 結合結果検証開始 ==="
result_size=$(du -b "${OUTPUT_FILE}" | cut -f1)
log "結合後ファイルサイズ: ${result_size} bytes"

if [ "${combined_size}" -ne "${result_size}" ]; then
    log "ERROR: ファイルサイズが一致しません"
    exit 1
fi

log "整合性チェック成功"

# 後処理
log "=== 後処理開始 ==="
log "一時ディレクトリ削除: ${TMP_DIR}"
rm -rf "${TMP_DIR}"

# オプション: 分割ファイル削除（必要に応じてコメントアウト解除）
log "=== 分割ファイル削除開始 ==="
rm -v poop.zip_part_*

log "=== 処理が正常に完了しました ==="
