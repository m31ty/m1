import requests
import os
from dotenv import load_dotenv

load_dotenv()
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
REPO_OWNER = os.getenv('REPO_OWNER')
REPO_NAME = os.getenv('REPO_NAME')
TAG_NAME = "v1.0"

HEADERS = {
	"Authorization": f"token {GITHUB_TOKEN}",
	"Accept": "application/vnd.github.v3+json"
}

#リリース情報を取得
release_url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/tags/{TAG_NAME}"
response = requests.get(release_url, headers=HEADERS)
response.raise_for_status()

#分割ファイルのアセットを抽出してソート
assets = response.json()['assets']
parts = [a for a in assets if a['name'].startswith('poop.zip_part_')]
parts.sort(key=lambda x: int(x['name'].split('_part_')[-1]))

#ファイルをダウンロード
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

#ファイルを結合
output_filename = 'poop.zip'
with open(output_filename, 'wb') as outfile:
	for part_file in downloaded_files:
		with open(part_file, 'rb') as infile:
			outfile.write(infile.read())

print(f"Successfully combined files into {output_filename}")

for part_file in downloaded_files:
	os.remove(part_file)
