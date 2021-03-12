# Example of managing OCP clusters using RHACM and Argo CD

Components used:
* [Red Hat Advanced Cluster Management](https://www.redhat.com/en/technologies/management/advanced-cluster-management) (RHACM)
* [Argo CD](https://argoproj.github.io/argo-cd/)
* [Kubernetes External Secrets](https://github.com/external-secrets/kubernetes-external-secrets) (formerly known as GoDaddy External Secrets)

Notes:

* Subscription merge option. Used for existing Kubernetes resources that are not owned by this Subscription. The resources are not deleted when the subscription is removed.
* Subscription replace option. Subscription owns the resources. When the subscription is removed, the resources will be removed too.
* Non-Git channels cannot be created in the same namespace

* Shortcomings: Cannot make Argo CD forget a resource (Prune=false) that was removed from git.

TODO:
* machinesets managed via machinepools
* Annotations:
```
argocd.argoproj.io/sync-options: Prune=false
argocd.argoproj.io/compare-options: IgnoreExtraneous
```

* Draw a diagram showing the directory structure
* Manifests for cluster provisioning

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
