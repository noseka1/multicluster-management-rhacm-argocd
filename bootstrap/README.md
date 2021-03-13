# Bootstrap

This directory contains a set of Kubernetes manifests that should be deployed on the Hub cluster.

First, find the values in the manifests that has to be replaced:

```
$ grep -rn REPLACE *
```

Edit the manifests and replace the values with your custom configuration.

Second, apply the manifests to the Hub cluster:

```
$ oc apply --kustomize .
```
