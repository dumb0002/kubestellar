## Quickstart

## Required Packages:
   - ko: https://ko.build/install/  (e.g., `brew install ko`)
   - gcc
   - jq
   - make
   - go (version expected 1.19 or higher)
   - kind
   - kubectl  

## 
1. Clone this repo:

```
git clone -b dev-env https://github.com/dumb0002/edge-mc.git
```

2. Deploy the kcp-edge Poc2023q1 example stage1:

```
sh install_edge-mc.sh
```

You should see an ouput similar to the one below:

```
kubectl ws tree
.
└── root
    ├── 1xvliuer0ueqb4wj-mb-9fe29fd1-fdcf-40d1-b87a-2aaf759f0401
    ├── 1xvliuer0ueqb4wj-mb-a3e8f741-bdb4-477e-8844-4518ac1ce082
    ├── compute
    ├── edge
    └── imw
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

3. Delete the kcp-edge Poc2023q1 example stage1:


```
sh delete_edge-mc.sh
```

