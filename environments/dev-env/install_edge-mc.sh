#!/usr/bin/env bash

#(1): Clone the kcp-playground tool
# rm -rf $(pwd)/edge-mc
# git clone -b dev-env https://github.com/dumb0002/edge-mc.git

#(2): Clone the kcp-playground tool
echo "****************************************"
echo "Clonining kcp-playground repo"
echo "****************************************"
rm -rf $(pwd)/kcp
git clone -b kcp-playground https://github.com/fabriziopandini/kcp.git

#(3): Move the kcp-playground yaml files to the target repo
mkdir $(pwd)/kcp/test/kubectl-kcp-playground/examples/kcp-edge/
cp stage1/*  $(pwd)/kcp/test/kubectl-kcp-playground/examples/kcp-edge/

#(4): build the binaries for kcp and kcp-playground plugin
echo "****************************************"
echo "Building kcp-playground binaries"
echo "****************************************"
cd $(pwd)/kcp
make build

#(5): Set up the kubeconfig and path variables
export PATH=$PATH:$(pwd)/bin
export KUBECONFIG=$(pwd)/.kcp-playground/playground.kubeconfig

#(6): Start the kcp-playground
echo "****************************************"
echo "Started deploying kcp-playground .... (waiting ~ 2 minutes)"
echo "****************************************"
rm -rf .kcp-playground/
kubectl kcp playground start -f test/kubectl-kcp-playground/examples/kcp-edge/poc2023q1-stage1.yml >& kcp-playground-log.txt &
sleep 120
echo "****************************************"
echo "Finished deploying kcp-playground .... (log file: kcp-playground-log.txt)"
echo "****************************************"

#(7): Start the edge-mc controller
echo "****************************************"
echo "Started deploying maibox-controller ...."
echo "****************************************"
cd ../../..
#cd $(pwd)/edge-mc
go run ./cmd/mailbox-controller --inventory-context=shard-main-root -v=2 >& mailbox-controller-log.txt &
echo "****************************************"
echo "Finshed deploying maibox-controller .... (log file: mailbox-controller-log.txt)"
echo "****************************************"
