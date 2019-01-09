#!/bin/bash

# This is my local linux script for starting this, uses network mode host to deal with dask and 127.0.0.1 + adjusts oom score and nice level

process_adjust() {
	sleep 5
	pgrep -f 'docker.*aibox' | xargs -i echo echo 1000 ">" /proc/\{\}/oom_score_adj | bash
	renice -n 19 -p $(pgrep -f jupyter-lab)
}

process_adjust &


nvidia-docker run --runtime=nvidia --rm --name aibox --ipc=host --network="host" -v /home/neuron/src/ml:/home/jovyan/work -v $HOME/tmp/pytorch:/home/jovyan/.torch/ aibox-githead
#nvidia-docker run --runtime=nvidia --rm --name aibox --ipc=host --network="host" -v /home/neuron/src/ml:/home/jovyan/work -v $HOME/tmp/pytorch:/home/jovyan/.torch/ andaag/aibox_cuda9
