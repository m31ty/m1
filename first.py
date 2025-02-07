import requests
import os
from dotenv import load_dotenv

load_dotenv()
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
REPO_OWNER = os.getenv('REPO_OWNER')
REPO_NAME = os.getenv('REPO_NAME')

HEADERS = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

def download_and_combine(tag_name, base_filename):
    """
    指定されたタグの分割ファイルをダウンロードし、結合する関数。
    """
    print(f"Processing files for tag: {tag_name}, base filename: {base_filename}")

    release_url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/tags/{tag_name}"
    response = requests.get(release_url, headers=HEADERS)
    response.raise_for_status()

    assets = response.json()['assets']
    parts = [a for a in assets if a['name'].startswith(f"{base_filename}_part_")]
    parts.sort(key=lambda x: int(x['name'].split('_part_')[-1]))

    downloaded_files = []
    for part in parts:
        url = part['browser_download_url']
        filename = part['name']
        print(f"Downloading {filename}...")

        response = requests.get(url, headers=HEADERS)
        response.raise_for_status()

        with open(filename, 'wb') as f:
            f.write(response.content)
        downloaded_files.append(filename)

    output_filename = base_filename
    with open(output_filename, 'wb') as outfile:
        for part_file in downloaded_files:
            with open(part_file, 'rb') as infile:
                outfile.write(infile.read())

    print(f"Successfully combined files into {output_filename}")

    for part_file in downloaded_files:
        os.remove(part_file)

# 例：poop.zip (v1.0) を処理
download_and_combine("v1.0", "poop.zip")

# 例：comics.zip (v2.0) を処理
download_and_combine("v2.0", "comics.zip")

# 必要であれば、他のファイルも同様に処理できる
# download_and_combine("v3.0", "another_file.zip")
