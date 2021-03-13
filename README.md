# Managing OCP/Kubernetes clusters using RHACM and Argo CD

Deploy using:

```
$ oc apply --kustomize bootstrap/
```

## Overview

Components used:
* [Red Hat Advanced Cluster Management](https://www.redhat.com/en/technologies/management/advanced-cluster-management) (RHACM)
  * Deploys new OpenShift clusters
  * Deploys External Secrets on the Hub cluster and managed clusters
  * Deploys Argo CD on the Hub cluster
  * Deploys AppProject and Application objects that instruct Argo CD how to configure clusters
* [Kubernetes External Secrets](https://github.com/external-secrets/kubernetes-external-secrets) (formerly known as GoDaddy External Secrets)
  * Fetches the secret data from HashiCorp Vault or possibly other sources and using the secret data it creates Kubernetes Secrets on the cluster.
* [Argo CD](https://argoproj.github.io/argo-cd/)
  * Manages clusters using the GitOps approach

## Directory structure

The repository consists of several top-level directories:

* *bootstrap* directory contains manifests that should be deployed first. This deployment can be automated using Ansible. The bootstrap manifests deploy External Secrets on the managed clusters. They also deploy Argo CD on the Hub cluster plus all Argo CD application configurations.
* *applications* directory contains Argo CD application configuration. These configurations are deployed by the *boostrap* manifests by RHACM. The *applications* directory contains Argo CD configuration for all managed clusters.
* *aggregates* directory contains kustomizations that are a combination of the kustomizations under the *manifests* directory. This allows us to use one kustomization in the *aggregates* directory to deploy an arbitrary number of kustomizations from the *manifests* directory. Note that the *aggregates* directory is meant only for combining the kustomizations. There is no overlay configuration in this directory. Overlays are defined in the *manifests* directory. Aggregates are deployed by Argo CD.
* *manifests* directory contains individual configurations applied to the clusters. They are typically grouped into aggregates so that they can be applied at once. This directory also contains overlays which allow to specify configuration differences between individual clusters/environments.

## Object management

Kubernetes objects can be divided into two groups.

1. Objects that are owned by the GitOps management. These objects are created and deleted by GitOps. Argo CD assumes by default that it owns all objects under its management. After the object has been deleted in the git repository, Argo CD will delete this object on the cluster during the next sync-up. In RHACM, we annotate the Subscription with `apps.open-cluster-management.io/reconcile-option: replace` to achieve a similar behaviour.

2. Objects that are modified by the GitOps management. These objects were created on the cluster by other means. GitOps is supposed to modify these objects but should never try to delete them. In Argo CD, we need to apply the following annotations to these objects: `argocd.argoproj.io/sync-options: Prune=false` and `argocd.argoproj.io/compare-options: IgnoreExtraneous`. This prevents Argo CD from ever trying to delete these ojects (Prune=false). At the same time Argo CD will mark the application in sync even after the managed object was removed from the git repository (IgnoreExtraneous). In RHACM, annotate the Subscription with `apps.open-cluster-management.io/reconcile-option: merge` to achieve similar behaviour.

TODO:
* machinesets managed via machinepools
* Draw a diagram showing the directory structure
* Manifests for cluster provisioning
* Shortcomings: Cannot make Argo CD forget a resource (Prune=false) that was removed from git.
* Non-Git channels cannot be created in the same namespace

## References

To create this repo, I draw ideas and inspiration from:

* https://github.com/PixelJonas/cluster-gitops
* https://github.com/gnunn-gitops/cluster-config
* https://github.com/christianh814/openshift-cluster-config
* https://github.com/kasuboski/k8s-gitops
* https://github.com/dgoodwin/openshift4-gitops
* https://github.com/siamaksade/openshift-gitops-getting-started
* https://github.com/sabre1041/rhacm-argocd
* https://github.com/christianh814/gitops-examples
* https://github.com/redhat-edge-computing/blueprint-management-hub
