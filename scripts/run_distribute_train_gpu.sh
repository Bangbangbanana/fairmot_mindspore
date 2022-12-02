#!/bin/bash
# bash run_standalone_train_gpu.sh [DATA_JSON] [VISIBLE_DEVICES(0,1,2,3,4,5,6,7)]
if [ $# -lt 2 ]; then
    echo "Usage: bash scripts/run_standalone_train_gpu.sh [DATA_JSON] [VISIBLE_DEVICES(0,1,2,3,4,5,6,7)]
    [DATA_JSON] stores training data information, 
    [VISIBLE_DEVICES] chooses which gpu devices will be used during training."
exit 1
fi

export PYTHONPATH=$PWD
echo "export PYTHONPATH=$PWD"

if [ ! -d "output" ]; then
    mkdir output
fi

DATA_JSON=$1
export CUDA_VISIBLE_DEVICES="$2"
devices=(${CUDA_VISIBLE_DEVICES//,/ })
NUM_DEVICES=${#devices[*]}
echo "Number of devices: $NUM_DEVICES"

user=$(env | grep USER | cut -d "=" -f 2)
if [ $user == "root" ]; 
then
    echo "Run as root"
    mpirun -n ${NUM_DEVICES} --allow-run-as-root python src/example/fairmot_mix_train.py --run_distribute True --data_json ${DATA_JSON} > output/train.log 2>&1 &
else
    echo "Run as $user"
    mpirun -n ${NUM_DEVICES} python src/example/fairmot_mix_train.py --run_distribute True --data_json ${DATA_JSON} > output/train.log 2>&1 &
fi