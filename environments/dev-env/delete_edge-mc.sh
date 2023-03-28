#!/usr/bin/env bash

pkill kubectl-kcp-playground
pkill kcp
pkill mailbox-controller
kind delete cluster --name florin
kind delete cluster --name guilder
rm -rf $(pwd)/kcp
