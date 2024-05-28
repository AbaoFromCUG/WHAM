#!/usr/bin/env bash

set -e
urle() {
	[[ "${1}" ]] || return 1
	local LANG=C i x
	for ((i = 0; i < ${#1}; i++)); do
		x="${1:i:1}"
		[[ "${x}" == [a-zA-Z0-9.~-] ]] && echo -n "${x}" || printf '%%%02X' "'${x}"
	done
	echo
}

if [ -f .env ]; then
	source .env
fi

if [[ ! -f dataset/body_models/smpl/SMPL_NEUTRAL.pkl ]]; then
	# SMPL Neutral model
	if [ -n "$SMPLIFY_USERNAME" ] && [ -n "$SMPLIFY_PASSWD" ]; then
		username=$SMPLIFY_USERNAME
		password=$SMPLIFY_PASSWD
	else
		echo -e "\nYou need to register at https://smplify.is.tue.mpg.de"
		read -p "Username (SMPLify):" username
		read -p "Password (SMPLify):" password
		username=$(urle $username)
		password=$(urle $password)
	fi

	mkdir -p dataset/body_models/smpl
	mkdir -p /tmp/dataset/body_models/smpl
	wget --post-data "username=$username&password=$password" 'https://download.is.tue.mpg.de/download.php?domain=smplify&resume=1&sfile=mpips_smplify_public_v2.zip' -O '/tmp/dataset/body_models/smplify.zip' --no-check-certificate --continue
	unzip /tmp/dataset/body_models/smplify.zip -d /tmp/dataset/body_models/smplify
	mv /tmp/dataset/body_models/smplify/smplify_public/code/models/basicModel_neutral_lbs_10_207_0_v1.0.0.pkl dataset/body_models/smpl/SMPL_NEUTRAL.pkl
	rm -rf /tmp/dataset
fi

if [[ ! -f dataset/body_models/smpl/SMPL_NEUTRAL.pkl ]]; then
	# SMPL Male and Female model
	if [ -n "$SMPL_USERNAME" ] && [ -n "$SMPL_PASSWD" ]; then
		username=$SMPL_USERNAME
		password=$SMPL_PASSWD
	else
		echo -e "\nYou need to register at https://smpl.is.tue.mpg.de"
		read -p "Username (SMPL):" username
		read -p "Password (SMPL):" password
		username=$(urle $username)
		password=$(urle $password)
	fi

	mkdir -p dataset/body_models/smpl
	mkdir -p /tmp/dataset/body_models/smpl
	wget --post-data "username=$username&password=$password" 'https://download.is.tue.mpg.de/download.php?domain=smpl&sfile=SMPL_python_v.1.0.0.zip' -O '/tmp/dataset/body_models/smpl.zip' --no-check-certificate --continue
	unzip /tmp/dataset/body_models/smpl.zip -d /tmp/dataset/body_models/smpl
	mv /tmp/dataset/body_models/smpl/smpl/models/basicModel_f_lbs_10_207_0_v1.0.0.pkl dataset/body_models/smpl/SMPL_FEMALE.pkl
	mv /tmp/dataset/body_models/smpl/models/basicmodel_m_lbs_10_207_0_v1.0.0.pkl dataset/body_models/smpl/SMPL_MALE.pkl
	rm -rf /tmp/dataset
fi

# Auxiliary SMPL-related data
if [ ! -f ./dataset/body_models/smplx2smpl.pkl ]; then
	mkdir -p /tmp/dataset/
	wget "https://drive.google.com/uc?id=1pbmzRbWGgae6noDIyQOnohzaVnX_csUZ&export=download&confirm=t" -O '/tmp/dataset/body_models.tar.gz'
	tar -xvf /tmp/dataset/body_models.tar.gz -C dataset/
	rm -rf /tmp/dataset
fi

ggdown() {
	url=$1
	path=$3
	if [ ! -f $path ]; then
		tmpfile=/tmp/$(uuidgen)
		gdown $url -O $tmpfile
		mv $tmpfile $path

	fi
}

# Checkpoints
mkdir -p checkpoints
ggdown "https://drive.google.com/uc?id=1i7kt9RlCCCNEW2aYaDWVr-G778JkLNcB&export=download&confirm=t" -O 'checkpoints/wham_vit_w_3dpw.pth.tar'
ggdown "https://drive.google.com/uc?id=19qkI-a6xuwob9_RFNSPWf1yWErwVVlks&export=download&confirm=t" -O 'checkpoints/wham_vit_bedlam_w_3dpw.pth.tar'
ggdown "https://drive.google.com/uc?id=1J6l8teyZrL0zFzHhzkC7efRhU0ZJ5G9Y&export=download&confirm=t" -O 'checkpoints/hmr2a.ckpt'
ggdown "https://drive.google.com/uc?id=1kXTV4EYb-BI3H7J-bkR3Bc4gT9zfnHGT&export=download&confirm=t" -O 'checkpoints/dpvo.pth'
ggdown "https://drive.google.com/uc?id=1zJ0KP23tXD42D47cw1Gs7zE2BA_V_ERo&export=download&confirm=t" -O 'checkpoints/yolov8x.pt'
ggdown "https://drive.google.com/uc?id=1xyF7F3I7lWtdq82xmEPVQ5zl4HaasBso&export=download&confirm=t" -O 'checkpoints/vitpose-h-multi-coco.pth'

# Demo videos
if [ ! -f examples/drone_video.mp4 ]; then
	ggdown "https://drive.google.com/uc?id=1KjfODCcOUm_xIMLLR54IcjJtf816Dkc7&export=download&confirm=t" -O '/tmp/examples.tar.gz'
	tar -xvf /tmp/examples.tar.gz -C /tmp
	rm -rf /tmp/examples.tar.gz
	mv /tmp/examples ./
fi
