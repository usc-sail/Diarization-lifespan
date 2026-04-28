#!/bin/bash

# Licensed under the MIT license.
# Copyright 2024 Brno University of Technology (author: Jiangyu Han, ihan@fit.vut.cz)
set -eu
ulimit -n 2048

# general setup
recipe_root=/YOUR_PATH/Diarization-lifespan/recipes/diar_ssl
exp_root=$recipe_root/exp
conf_dir=$recipe_root/conf


segmentation_model=/YOUR_PATH/whisper_medium_16s_playlogue.bin  # train your own or download from hugginface
conf_name=whisper_medium_16s_playlogue
# inference setup
dtype=test

seg_duration=16

# clustering setup
clustering_method=AgglomerativeClustering
ahc_threshold=0.70
min_cluster_size=30
infer_affix=_constrained_AHC_thres_${ahc_threshold}_mcs_${min_cluster_size}

avg_ckpt_num=1
val_metric=Loss   # Loss or DER
val_mode=best   # [prev, best, center]  

# scoring setup
collar=0

dscore_dir=/YOUR_PATH/Diarization-lifespan/dscore


diarization_dir=$conf_dir/$conf_name    # can be replaced by our pre-trained models, e.g. diarization_dir=/YOUR_PATH/checkpoints/wavlm_updated_conformer
config_dir=`ls $diarization_dir/*.toml | sort -r | head -n 1`
embedding_model=/YOUR_PATH/pretrained/pyannote3/wespeaker-voxceleb-resnet34-LM/pytorch_model.bin     # it's necessary to have "pyannote" in your directory path

echo "model inference..."
export CUDA_VISIBLE_DEVICES=2

dset=Playlogue
data_dir=$recipe_root/data/$dset
REF_DIR=$data_dir

python infer_avg.py -C $config_dir \
    -i ${data_dir}/${dtype}/wav.scp \
    -o ${diarization_dir}/infer$infer_affix/metric_${val_metric}_${val_mode}/avg_ckpt${avg_ckpt_num}/${dtype}/${dset} \
    --embedding_model $embedding_model \
    --avg_ckpt_num $avg_ckpt_num \
    --val_metric $val_metric \
    --val_mode $val_mode \
    --segmentation_model $segmentation_model \
    --seg_duration $seg_duration \
    --clustering_method $clustering_method \
    --ahc_threshold $ahc_threshold \
    --min_cluster_size $min_cluster_size 

echo "scoring..."
SYS_DIR=${diarization_dir}/infer$infer_affix/metric_${val_metric}_${val_mode}/avg_ckpt${avg_ckpt_num}
OUT_DIR=${SYS_DIR}/${dtype}/${dset}
python ${dscore_dir}/score.py \
    -r ${REF_DIR}/${dtype}/rttm \
    -s $OUT_DIR/*.rttm --collar ${collar} \
    > $OUT_DIR/result_collar${collar}