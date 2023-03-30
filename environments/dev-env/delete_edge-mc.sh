#!/usr/bin/env bash

pkill kubectl-kcp-playground
pkill kcp
pkill mailbox-controller
pkill main # edge-scheduler
kind delete cluster --name florin
kind delete cluster --name guilder
rm -rf $(pwd)/kcp
echo "Finished deletion ...."