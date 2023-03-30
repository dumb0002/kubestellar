## Quickstart

## Required Packages:
   - ko: https://ko.build/install/ 
   - gcc
   - jq
   - make
   - go (version expected 1.19)
   - kind
   - kubectl  

For Mac OS:
```
brew install ko gcc jq make go kind kubectl
```

## 
1. Clone this repo:

```
git clone -b dev-env https://github.com/dumb0002/edge-mc.git
```

2. Experiment with the kcp-edge 2023q1 PoC example scenarios at: https://docs.kcp-edge.io/docs/coding-milestones/poc2023q1/example1/

## Stage 1:

Stage 1 creates the infrastructure and the edge service provider workspace and lets that react to the inventory

```
sh install_edge-mc.sh --stage 1
```

You should see an ouput similar to the one below:

```
kubectl ws tree
.
└── root
    ├── compute
    ├── espw
    │   ├── 2sw7hflwls2yqcad-mb-7f38a3a2-b90f-4f68-a00d-44ba0b34e366
    │   └── 2sw7hflwls2yqcad-mb-a57adcc9-b878-4891-802c-e4b75abf2c3b
    ├── imw
```

```
kubectl ws root:imw
kubectl get locations
NAME         RESOURCE      AVAILABLE   INSTANCES   LABELS   AGE
default      synctargets   0           2                    2m58s
location-f   synctargets   0           1                    2m59s
location-g   synctargets   0           1                    2m59s

kubectl get synctargets
NAME            AGE
sync-target-f   3m6s
sync-target-g   3m5s
```

```
kind get clusters
florin
guilder
```

## Stage 2:

Stage 2 creates two workloads, called “common” and “special” and in response to each EdgePlacement, the edge scheduler creates the corresponding SinglePlacementSlice object.

```
sh install_edge-mc.sh --stage 2
```

You should see an ouput similar to the one below:

```
kubectl ws tree
.
└── root
    ├── compute
    ├── espw
    │   ├── 2sw7hflwls2yqcad-mb-7f38a3a2-b90f-4f68-a00d-44ba0b34e366
    │   └── 2sw7hflwls2yqcad-mb-a57adcc9-b878-4891-802c-e4b75abf2c3b
    ├── imw
    ├── wmw-c
    └── wmw-s
```

For workload common:
```
$ kubectl ws wmw-c
Current workspace is "root:wmw-c" (type root:universal).

$ kubectl get ns
NAME          STATUS   AGE
commonstuff   Active   99s
default       Active   104s

$ kubectl -n commonstuff get deploy
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
commond   0/0     0            0           111s

$ kubectl -n commonstuff get configmaps
NAME               DATA   AGE
httpd-htdocs       1      117s
kube-root-ca.crt   1      117s

$ kubectl get SinglePlacementSlice
NAME               AGE
edge-placement-c   111s
```

For workload special:
```
$ kubectl ws wmw-s
Current workspace is "root:wmw-s" (type root:universal).

$ kubectl get ns
NAME           STATUS   AGE
default        Active   5m1s
specialstuff   Active   4m57s

$ kubectl -n specialstuff  get deploy
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
speciald   0/0     0            0           5m29s

$ kubectl -n specialstuff  get configmaps
NAME               DATA   AGE
httpd-htdocs       1      5m35s
kube-root-ca.crt   1      5m35s

$ kubectl get SinglePlacementSlice
NAME               AGE
edge-placement-s   5m26s
```

3. Delete a kcp-edge Poc2023q1 example stage:

```
sh delete_edge-mc.sh
```

