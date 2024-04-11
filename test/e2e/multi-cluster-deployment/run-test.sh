#!/usr/bin/env bash
# Copyright 2024 The KubeStellar Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is an end to end test of multi cluster deployement.
# For readable instructions, please visit ../../../docs/content/direct

#set -x # so users can see what is going on

env="kind"

if [ "$1" == "--released" ]; then
    setup_flags="$1"
    shift
fi

if [ "$1" == "--env" ]; then
    env="$2"
    shift 2
fi

if [ "$#" != 0 ]; then
    echo "Usage: $0 [--released or/and --env kind/ocp]" >& 2
    exit 1
fi

set -e # exit on error

if [ $env == "kind" ];then
    SRC_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
    COMMON_SRCS="${SRC_DIR}/../common"
    HACK_DIR="${SRC_DIR}/../../../hack"

    "${HACK_DIR}/check_pre_req.sh" --assert --verbose kubectl docker kind make go ko yq helm kflex ocm

    "${COMMON_SRCS}/cleanup.sh"
    source "${COMMON_SRCS}/setup-shell.sh"
    "${COMMON_SRCS}/setup-kubestellar.sh" $setup_flags
    "${SRC_DIR}/use-kubestellar.sh"

elif [ $env == "ocp" ];then
   bash <(curl -s https://raw.githubusercontent.com/kubestellar/kubestellar/release-$KUBESTELLAR_VERSION/test/e2e/common/cleanup.sh) --env ocp
   source <(curl -s https://raw.githubusercontent.com/kubestellar/kubestellar/release-$KUBESTELLAR_VERSION/test/e2e/common/setup-shell.sh)
   bash <(curl -s https://raw.githubusercontent.com/kubestellar/kubestellar/release-$KUBESTELLAR_VERSION/test/e2e/common/setup-kubestellar-ocp.sh)
   bash <(curl -s https://raw.githubusercontent.com/kubestellar/kubestellar/release-$KUBESTELLAR_VERSION/test/e2e/multi-cluster-deployment/use-kubestellar.sh) --env ocp
else

   echo "$0: unknown flag option" >&2 ;
   echo "Usage: $0 [--env kind or --env ocp]" >& 2
   exit 1
fi

