import os
import pathlib
import sys
from pathlib import Path
import uuid
import numpy as np

from flask import Blueprint, Flask, current_app, flash, jsonify, redirect, request

sys.path.append("/code")

from wham_api import WHAM_API

wham_bp = Blueprint("wham", __name__)


wham_model = WHAM_API()


def gen_uuid():
    return str(uuid.uuid4())


@wham_bp.route("/")
def index():
    return jsonify({"code": 0, "data": "Hello"})



from wham_api import WHAM_API
wham_model = WHAM_API()
input_video_path = 'examples/IMG_9732.mov'
results, tracking_results, slam_results = wham_model(input_video_path)


def prepare_serde(obj: dict):
    copy_obj = dict()
    for k, v in obj.items():
        if type(v) == np.ndarray:
            copy_obj[k] = v.flatten().tolist()
            copy_obj[f"{k}__shape"] = v.shape
        elif isinstance(v, dict):
            copy_obj[k] = prepare_serde(v)
        else:
            copy_obj[k] = v
results = prepare_serde(results)
import json
json.dumps(results)


@wham_bp.route("/inference", methods=["GET", "POST"])
def inference():
    support_type = set([".mp4", ".avi"])
    if request.method == "POST":
        # check if the post request has the file part
        if "file" not in request.files:
            return jsonify({"code": 1, "error": "No file part"})
        file = request.files["file"]
        if file.filename == "" or file.filename is None:
            return jsonify({"code": 2, "error": "No selected file"})
        filename = Path(file.filename)
        if filename.suffix.lower() in support_type:
            filepath = Path(current_app.config["TEMP_PATH"])
            filepath = filepath.joinpath(f"{gen_uuid()}{filename.suffix}")
            file.save(str(filepath))
            return jsonify({"code": 0, "data": {"url": str(filepath)}})
        else:
            return jsonify({"code": 3, "error": f"unknown filename:{str(filename)}"})
    return """
    <!doctype html>
    <title>Upload new File(TEST!!!!!)</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    """


def create_app(test_config=None):
    app = Flask(__name__)

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile("config.py", silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    temp_root = Path(app.config["TEMP_PATH"])

    app.register_blueprint(wham_bp, url_prefix="/wham")

    return app
