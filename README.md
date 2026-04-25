# Forked and modified from DiariZen.

## Installation
```
# create virtual python environment
conda create --name diarizen python=3.10
conda activate diarizen

# install diarizen 
conda install pytorch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 pytorch-cuda=12.1 -c pytorch -c nvidia
conda install -y -c conda-forge "mkl<2024.1" "intel-openmp<2024.1"
pip install -r requirements.txt && pip install -e .

# install pyannote-audio
cd pyannote-audio && pip install -e .[dev,testing] --no-deps

# install dscore
git submodule init
git submodule update
```

## Usage
- For model training and inference, see `recipes/diar_ssl/run_stage.sh`. 

## Citations
If you found this work helpful, please consider citing
```
@article{xu2026exploring,
  title={Exploring Speech Foundation Models for Speaker Diarization Across Lifespan},
  author={Xu, Anfeng and Feng, Tiantian and Narayanan, Shrikanth},
  journal={arXiv preprint arXiv:2604.05201},
  year={2026}
}
```


## License
- The **code** in this repository is licensed under the [MIT license](https://github.com/BUTSpeechFIT/DiariZen/blob/main/LICENSE).
- The **pre-trained model weights** are released strictly for **research and non-commercial use only**, in accordance with the licenses of the datasets used for training. Commercial use of the model weights is prohibited. See [MODEL_LICENSE](https://github.com/BUTSpeechFIT/DiariZen/blob/main/MODEL_LICENSE) for details.


