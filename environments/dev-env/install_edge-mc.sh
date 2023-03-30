#!/usr/bin/env bash

set -e

stage=""

while (( $# > 0 )); do
    if [ "$1" == "--stage" ]; then
        stage=$2
    fi 
    shift
done

# Check if docker is running
if ! docker ps
then
  echo "Docker Not running ...."
  exit
fi

# Check go version
go_version=`go version | { read _ _ v _; echo ${v#go}; }`

if [ $go_version != "1.19" ]
then
  echo "Go version must be 1.19 ...."
  exit
fi

#(1): Clone the kcp-playground tool
echo "****************************************"
echo "Clonining kcp-playground repo"
echo "****************************************"
rm -rf $(pwd)/kcp
git clone -b kcp-playground https://github.com/fabriziopandini/kcp.git

#(2): Move the kcp-playground yaml files to the target repo
mkdir $(pwd)/kcp/test/kubectl-kcp-playground/examples/kcp-edge/
cp stages/*  $(pwd)/kcp/test/kubectl-kcp-playground/examples/kcp-edge/

#(3): build the binaries for kcp and kcp-playground plugin
echo "****************************************"
echo "Building kcp-playground binaries"
echo "****************************************"
cd $(pwd)/kcp
make build

#(4): Set up the kubeconfig and path variables
kcp_path=$(pwd)/bin
kubeconfig_path=$(pwd)/.kcp-playground/playground.kubeconfig
export PATH=$PATH:$kcp_path
export KUBECONFIG=$kubeconfig_path

#(5): Start the kcp-playground
echo "****************************************"
echo "Started deploying kcp-playground: complete in ~ 2m30sec (maximum waiting time: 5 minutes)"
echo "****************************************"
rm -rf .kcp-playground/

if [ $stage == 1 ]; then  
    kubectl kcp playground start -f test/kubectl-kcp-playground/examples/kcp-edge/poc2023q1-stage1.yml >& kcp-playground-log.txt &
elif [ $stage == 2 ]; then
    kubectl kcp playground start -f test/kubectl-kcp-playground/examples/kcp-edge/poc2023q1-stage2.yml >& kcp-playground-log.txt &
fi 

####################################################
MAX_RETRIES=20 # maximum wait: 5 minutes
retries=0
sucess=1

fname=".kcp-playground/playground.kubeconfig"

while [ $retries -le "$MAX_RETRIES" ]; do
    #echo $retries
    retries=$(( retries + 1 ))

    if [ -f $fname ]; then
        sucess=0
        break
    fi

    sleep 15
    sec=$(( retries * 15 ))
    echo "Waited $sec seconds"
done

if [ $sucess == 1 ]; then
   echo "kcp-playground kubeconfig not generated - maximum waiting time exceeded: 5 minutes"
   exit 
fi 
####################################################
echo "****************************************"
echo "Finished deploying kcp-playground .... (log file: kcp-playground-log.txt)"
echo "****************************************"


#(6): Start the edge-mc controller
echo "****************************************"
echo "Started deploying maibox-controller ...."
echo "****************************************"
cd ../../..

kubectl ws root:espw
go run ./cmd/mailbox-controller --inventory-context=shard-main-root -v=2 >& mailbox-controller-log.txt &
echo "****************************************"
echo "Finished deploying maibox-controller .... (log file: mailbox-controller-log.txt)"
echo "****************************************"


if [ $stage != 1 ]; then 
    # (7): Start the edge-mc scheduler
    echo "****************************************"
    echo "Started deploying edge scheduler...."
    echo "****************************************"
    sleep 10
    kubectl ws root:espw
    go run cmd/scheduler/main.go -v 2 --kcp-kubeconfig=$kubeconfig_path >& edge-scheduler-log.txt &
    echo "****************************************"
    echo "Finished deploying edge scheduler...."
    echo "****************************************"
fi

kubectl ws root
echo "KCP-Edge dev-env successfully started"
echo "To start using the KCP-Edge dev-env: "
echo "   export KUBECONFIG=kcp/.kcp-playground/playground.kubeconfig"