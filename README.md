# Example of managing OCP clusters using RHACM

* Subscription merge option. Used for existing Kubernetes resources that are not owned by this Subscription. The resources are not deleted when the subscription is removed.
* Subscription replace option. Subscription owns the resources. When the subscription is removed, the resources will be removed too.
* Non-Git channels cannot be created in the same namespace

## References

To create this repo, I draw ideas and inspiration from:

* https://github.com/PixelJonas/cluster-gitops
* https://github.com/gnunn-gitops/cluster-config
* https://github.com/christianh814/openshift-cluster-config
