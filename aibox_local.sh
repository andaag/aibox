#!/bin/bash

# This is my local linux script for starting this, uses network mode host to deal with dask and 127.0.0.1 + adjusts oom score and nice level

process_adjust() {
	sleep 5
	PID=$(pgrep -f 'docker.*aibox')
	echo 1000 > /proc/$PID/oom_score_adj
	renice -n 19 -p $(pgrep -f jupyter-lab)
	echo "Adjusted pid $PID to oom_score_adj 1000"
}

process_adjust &


nvidia-docker run --runtime=nvidia --rm --name aibox --network="host" -v /home/neuron/:/home/jovyan/work -v $HOME/tmp/pytorch:/home/jovyan/.torch/ aibox-githead
