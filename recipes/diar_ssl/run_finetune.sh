#!/bin/bash

# Licensed under the MIT license.
# Copyright 2024 Brno University of Technology (author: Jiangyu Han, ihan@fit.vut.cz)

set -eu
ulimit -n 2048

# general setup
stage=1
recipe_root=/YOUR_PATH/DiariZen/recipes/diar_ssl
exp_root=$recipe_root/exp
conf_dir=$recipe_root/conf

# training setup
use_dual_opt=false  
train_conf=$conf_dir/whisper_medium_16s_playlogue.toml

conf_name=`ls $train_conf | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}'`

# inference setup
dtype=test
data_dir=$recipe_root/data/Playlogue
seg_duration=8

# clustering setup
clustering_method=AgglomerativeClustering
ahc_threshold=0.70
min_cluster_size=30
infer_affix=_constrained_AHC_thres_${ahc_threshold}_mcs_${min_cluster_size}

avg_ckpt_num=5
val_metric=Loss   # Loss or DER
val_mode=best   # [prev, best, center]  

# scoring setup
collar=0
REF_DIR=$data_dir
dscore_dir=/YOUR_PATH/DiariZen/dscore

# =======================================
# =======================================
if [ $stage -le 1 ]; then
    if (! $use_dual_opt); then
        echo "stage1: use single-opt for model training..."
        conda activate diarizen && CUDA_VISIBLE_DEVICES="0,1" accelerate launch \
            run_single_opt.py -C $train_conf -M validate
    else
        echo "stage1: use dual-opt for model training..."
        conda activate diarizen && CUDA_VISIBLE_DEVICES="0,1,2,3" accelerate launch \
            run_dual_opt.py -C $train_conf -M train
    fi
fi

diarization_dir=$exp_root/$conf_name    # can be replaced by our pre-trained models, e.g. diarization_dir=/YOUR_PATH/checkpoints/wavlm_updated_conformer
config_dir=`ls $diarization_dir/*.toml | sort -r | head -n 1`
embedding_model=/YOUR_PATH/pretrained/pyannote3/wespeaker-voxceleb-resnet34-LM/pytorch_model.bin     # it's necessary to have "pyannote" in your directory path

i