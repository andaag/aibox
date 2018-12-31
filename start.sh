#!/bin/bash
set -e
set -m
#source $HOME/.bashrc

ldconfig
echo "Executing as $1"
sudo -s -H -u $1 env "PATH=$PATH" jupyter lab --ip 0.0.0.0 --NotebookApp.password='sha1:a60ff295d0b9:506732d050d4f50bfac9b6d6f37ea6b86348f4ed' &
sleep 0.5
rm -f /usr/bin/sudo
fg
