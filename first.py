import requests
import os
from dotenv import load_dotenv
import concurrent.futures
from tqdm import tqdm

load_dotenv()
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
REPO_OWNER = os.getenv('REPO_OWNER')
REPO_NAME = os.getenv('REPO_NAME')

HEADERS = {
	"Authorization": f"token {GITHUB_TOKEN}",
	"Accept": "application/vnd.github.v3+json"
}

def download_part(part):
	url = part['browser_download_url']
	filename = part['name']
	print(f"Downloading {filename}...")
	response = requests.get(url, headers=HEADERS, stream=True)
	response.raise_for_status()
	total_size_in_bytes = int(response.headers.get('content-length', 0))
	block_size = 1024  #1 Kibibyte
	progress_bar = tqdm(total=total_size_in_bytes, unit='iB', unit_scale=True, desc=filename)

	with open(filename, 'wb') as f:
		for data in response.iter_content(block_size):
			progress_bar.update(len(data))
			f.write(data)
	progress_bar.close()
	if total_size_in_bytes != 0 and progress_bar.n != total_size_in_bytes:
		print("ERROR, something went wrong")

	return filename

def combine_files(downloaded_files, output_filename):
	with open(output_filename, 'wb') as outfile:
		for part_file in downloaded_files:
			with open(part_file, 'rb') as infile:
				while True:
					chunk = infile.read(4096 * 1024)
					if not chunk:
						break
					outfile.write(chunk)
			os.remove(part_file)
	print(f"Successfully combined files into {output_filename}")

def download_and_combine(tag_name, base_filename):
	print(f"Processing files for tag: {tag_name}, base filename: {base_filename}")
	release_url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/tags/{tag_name}"
	response = requests.get(release_url, headers=HEADERS)
	response.raise_for_status()
	assets = response.json()['assets']
	parts = [a for a in assets if a['name'].startswith(f"{base_filename}_part_")]
	parts.sort(key=lambda x: int(x['name'].split('_part_')[-1]))

	#並列ダウンロード
	with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
		downloaded_files = list(executor.map(download_part, parts))

	#ファイル結合
	output_filename = base_filename
	combine_files(downloaded_files, output_filename)

#実行部分
if __name__ == "__main__":
	tasks = [
	  ("v1.0", "poop.zip"),
	  ("v2.0", "comics.zip"),
	  #("v3.0", "Golgo.13.zip")
	]

	#全体の処理も並列化する場合 (必要に応じて)
	with concurrent.futures.ThreadPoolExecutor() as executor:
		executor.map(lambda args: download_and_combine(*args), tasks)

	#通常の逐次実行(GitHub Actionsの同時実行数に制限がある場合など)
#	for task in tasks:
#	  download_and_combine(*task)
#	print("DL zip finished")
