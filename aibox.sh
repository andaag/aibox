#!/bin/bash
nvidia-docker run --runtime=nvidia --rm --name aibox -p 8888:8888 -v /home/neuron/src/ml:/home/jovyan/work -v $HOME/tmp/pytorch:/home/jovyan/.torch/ aibox
