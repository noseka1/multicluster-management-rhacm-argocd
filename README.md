# Example of managing OCP clusters using RHACM and Argo CD

Components used:
* [Red Hat Advanced Cluster Management](https://www.redhat.com/en/technologies/management/advanced-cluster-management) (RHACM)
* [Argo CD](https://argoproj.github.io/argo-cd/)
* [Kubernetes External Secrets](https://github.com/external-secrets/kubernetes-external-secrets) (formerly known as GoDaddy External Secrets)


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
