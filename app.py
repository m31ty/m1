import os
from functools import wraps
from flask import Flask, send_file, render_template, abort, session, redirect, url_for, request
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
import subprocess
#import first

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'  #本番環境では強力なシークレットキーを使用
app.config['MOVIE_FOLDER'] = 'movies'
app.config['COMICS_FOLDER'] = 'comics'
app.config['THUMBNAIL_FOLDER'] = 'static/thumbnails'

from dotenv import load_dotenv

load_dotenv()
USNM = os.getenv('USNM')
PSWD = os.getenv('PSWD')
users = {
	USNM: generate_password_hash(PSWD)
}

def login_required(f):
	@wraps(f)
	def decorated_function(*args, **kwargs):
		if not session.get('logged_in'):
			return redirect(url_for('login', next=request.url))
		return f(*args, **kwargs)
	return decorated_function

def generate_thumbnail(video_path):
	os.makedirs(app.config['THUMBNAIL_FOLDER'], exist_ok=True)
	base_name = os.path.splitext(os.path.basename(video_path))[0]
	thumbnail_path = os.path.join(app.config['THUMBNAIL_FOLDER'], base_name + '.jpg')

	if not os.path.exists(thumbnail_path):
		try:
			subprocess.run([
				'ffmpeg', '-i', video_path,
				'-ss', '00:00:01', '-vframes', '1',
				'-q:v', '2',
				thumbnail_path,
				'-loglevel', 'quiet'
			], check=True)
		except Exception as e:
			print(f"サムネイル生成エラー: {e}")
			return None

	return os.path.relpath(thumbnail_path, start='static')

def get_file_type(path):
	if os.path.isdir(path):
		return 'folder'
	elif path.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
		return 'video'
	elif path.lower().endswith('.zip'):
		return 'zip'
	return 'other'

def list_directory(base, path):
	full_path = os.path.join(base, path)
	if not os.path.exists(full_path) or not os.path.isdir(full_path):
		abort(404)

	#アイテムを収集して分類
	folders = []
	videos = []
	zips = []
	others = []

	for name in sorted(os.listdir(full_path)):
		item_path = os.path.join(full_path, name)
		rel_path = os.path.join(path, name).replace('\\', '/')
		file_type = get_file_type(item_path)
		
		item = {
			'name': name,
			'type': file_type,
			'path': rel_path,
		}

		#タイプ別に分類
		if file_type == 'folder':
			folders.append(item)
		elif file_type == 'video':
			thumbnail = generate_thumbnail(item_path)
			item['thumbnail'] = thumbnail if thumbnail else ''
			videos.append(item)
		elif file_type == 'zip':
			zips.append(item)
		else:
			others.append(item)

	#ソート順序:フォルダ → 動画 → ZIP → その他
	sorted_items = []
	sorted_items.extend(sorted(folders, key=lambda x: x['name'].lower()))
	sorted_items.extend(sorted(videos, key=lambda x: x['name'].lower()))
	sorted_items.extend(sorted(zips, key=lambda x: x['name'].lower()))
	sorted_items.extend(sorted(others, key=lambda x: x['name'].lower()))

	base_type = 'movie' if base == app.config['MOVIE_FOLDER'] else 'comic'
	return render_template('listing.html', 
						 items=sorted_items,
						 is_root=path == '',
						 base_type=base_type,
						 current_path=path)

@app.route('/login', methods=['GET', 'POST'])
def login():
	if request.method == 'POST':
		username = request.form['username']
		password = request.form['password']
		
		if username in users and check_password_hash(users[username], password):
			session['logged_in'] = True
			session['username'] = username
			return redirect(url_for('index'))
		return render_template('login.html', error='Invalid credentials!')
	return render_template('login.html')

@app.route('/logout')
def logout():
	session.pop('logged_in', None)
	session.pop('username', None)
	return redirect(url_for('login'))

@app.route('/')
@login_required
def index():
	return render_template('index.html')

@app.route('/movies')
@app.route('/movies/<path:subpath>')
@login_required
def movie_listing(subpath=''):
	return list_directory(app.config['MOVIE_FOLDER'], subpath)

@app.route('/comics')
@app.route('/comics/<path:subpath>')
@login_required
def comic_listing(subpath=''):
	return list_directory(app.config['COMICS_FOLDER'], subpath)

@app.route('/video/<path:filename>')
@login_required
def stream_video(filename):
	video_path = os.path.join(app.config['MOVIE_FOLDER'], filename)
	if not os.path.exists(video_path):
		abort(404)
	return send_file(video_path, mimetype='video/mp4')

@app.route('/download/<path:filename>')
@login_required
def download_file(filename):
	file_path = os.path.join(app.config['COMICS_FOLDER'], filename)
	if not os.path.exists(file_path):
		abort(404)
	return send_file(file_path, as_attachment=True)


if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5000, debug=False)
