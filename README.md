# Managing multiple OpenShift/Kubernetes clusters using RHACM and Argo CD

## Overview

Components used:
* [Kubernetes External Secrets](https://github.com/external-secrets/kubernetes-external-secrets) (formerly known as GoDaddy External Secrets)
  * Fetches the secret data from HashiCorp Vault or possibly other sources and using this secret data it creates Kubernetes Secrets on the cluster.
* [Red Hat Advanced Cluster Management](https://www.redhat.com/en/technologies/management/advanced-cluster-management) (RHACM)
  * Deploys new OpenShift clusters
  * Deploys External Secrets on the Hub cluster and managed clusters
  * Deploys Argo CD on the Hub cluster
  * Deploys AppProject and Application objects that instruct Argo CD how to configure clusters
* [Argo CD](https://argoproj.github.io/argo-cd/)
  * Manages clusters using the GitOps approach

## Deploying

The `boostrap` directory contains a set of Kubernetes manifests that need to be deployed to the Hub cluster.

First, find the values in those manifests that have to be replaced:

```
$ grep -rn REPLACE *
```

Edit the manifests and replace the values with your custom configuration.

Second, apply the manifests to the Hub cluster:

```
$ oc apply --kustomize bootstrap/external-secrets
```

```
$ oc apply --kustomize bootstrap/gitops-namespace
```

```
$ oc apply --kustomize bootstrap/gitops-operator
```

```
$ oc apply --kustomize bootstrap/argocd-apps
```

## Directory structure

The repository consists of several top-level directories:

* *bootstrap* directory contains manifests that should be deployed first. This deployment can be automated using Ansible. Bootstrap manifests deploy Kubernetes External Secrets operator to the managed clusters. They also deploy Argo CD on the Hub cluster plus all Argo CD application manifests.
* *applications* directory contains Argo CD application manifests. These manifests are deployed by RHACM after the manifests from the *boostrap* directory have been applied. The *applications* directory contains Argo CD application configuration for all managed clusters.
* *aggregates* directory contains kustomizations that combine the kustomizations from the *manifests* directory. After applying a kustomization from the *aggregates* directory, an arbitrary number of kustomizations from the *manifests* directory are applied in one shot. Note that the *aggregates* directory is meant only for combining the kustomizations. There is no overlay configuration in this directory. Overlays are defined in the *manifests* directory. Aggregates are deployed by the Argo CD applications.
* *manifests* directory contains individual configurations applied to the clusters. They are typically grouped into aggregates so that they can be applied at once. This directory also contains overlays which allow to specify configuration differences between individual clusters/environments.

## Object management

Kubernetes objects can be divided into two categories:

1. Objects that are owned by the GitOps management. These objects are created and deleted by GitOps. Argo CD assumes by default that it owns all objects under its management. After the object has been deleted in the git repository and the object is allowed to be pruned, Argo CD will delete this object on the cluster during the next sync-up. In RHACM, we annotate the Subscription with `apps.open-cluster-management.io/reconcile-option: replace` to achieve a similar behaviour.

2. Objects that are modified by the GitOps management. These objects were created on the cluster by other means. GitOps is supposed to modify these objects but should never try to delete them. In Argo CD, we apply the following annotation to these objects: `argocd.argoproj.io/sync-options: Prune=false`. This prevents Argo CD from deleting these ojects (Prune=false) after they have been removed from the git repository even when the sync operation was executed with `prune=true`. Note that Argo CD will still try to delete the object if you for example delete your application using `argocd app delete --cascade` or if you click Delete in the Web UI. In RHACM, annotate the Subscription with `apps.open-cluster-management.io/reconcile-option: merge` to prevent RHACM from ever trying to delete the object.

### Why is Argo CD's auto prune disabled in this repo?

In this repo, the automated prune of Argo CD applications is disabled by setting `spec.syncPolicy.automated.prune: false` like this:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example
spec:
  syncPolicy:
    automated:
      prune: false
```

If the Argo CD's auto prune was enabled for an application named `example`, then Argo CD would delete all objects that belong to this application and do not exist in git anymore. How does Argo CD discover these objects when they are not represented in git? Argo CD looks at the `app.kubernetes.io/instance` label and matches its value against the application name. So, why can automated prune be a problem? Some cluster operators may create objects with this label set. If that happens, Argo CD will delete these objects as they don't exist in the git repository. An example of such object is ManagedClusterInfo created by RHACM. Also, deleting cluster objects feels safer when they need to be removed from git first and then pruned before they get deleted for real.

### Why is Argo CD's self-heal enabled in this repo?

* If the cluster's state has been changed (for example manually by the user) and it now differs from the state in git, Argo CD should restore the cluster state to match the configuration in git.
* If the reconciliation of objects on the cluster fails, we would like Argo CD to keep trying. This is what other OpenShift operators typically do, they keep trying until the object is reconciled successfully.

## Video

[![How to Manage Multiple Clusters Using RHACM and Argo CD](https://img.youtube.com/vi/b7Q3KvgA48Q/0.jpg)](http://www.youtube.com/watch?v=b7Q3KvgA48Q)

## TODO

* Shortcomings: Cannot make Argo CD forget a resource (Prune=false) that was removed from git, need to remove the label.
* Non-Git channels cannot be created in the same namespace
* Add my kustomizations to the content list below.

## References

To create this repo, I drew ideas and inspiration from:

* https://github.com/PixelJonas/cluster-gitops
* https://github.com/gnunn-gitops/cluster-config
* https://github.com/christianh814/openshift-cluster-config
* https://github.com/kasuboski/k8s-gitops
* https://github.com/dgoodwin/openshift4-gitops
* https://github.com/siamaksade/openshift-gitops-getting-started
* https://github.com/sabre1041/rhacm-argocd
* https://github.com/christianh814/gitops-examples
* https://github.com/redhat-edge-computing/blueprint-management-hub

Content that can be installed on the cluster via Argo CD:

* https://github.com/redhat-canada-gitops/catalog
* https://github.com/AlyIbrahim/openshift-add-ons
* https://github.com/hornjason/argocd-lab
