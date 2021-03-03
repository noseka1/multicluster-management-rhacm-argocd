# Allowing External Secrets to fetch secret data from HashiCorp Vault that is running on a remote Kubernetes cluster

External Secrets assume that HashiCorp Vault instance is running on the same Kubernetes cluster as the External Secrets operator. To allow External Secrets to fetch secret data from Vault running on a remote Kubernetes cluster, the External Secrets need to use an authentication token that allows it to authenticate against the remote Kubernetes cluster. The location from where the External Secrets operator reads the authentication token was hard-coded in the operator. Modifying the existing code to allow External Secrets to grab a token from an arbitrary location specified by the CUSTOM_KUBERNETES_TOKEN_PATH environment variable. The idea is that a secret that contains the remote authentication token will be mounted at this location.

Build the custom External Secrets container image:

```
$ podman build \
  --tag kubernetes-external-secrets:6.3.0-patch1 \
  .
```

Push the image to the image registry. For example:

```
$ podman push kubernetes-external-secrets:6.3.0-patch1 quay.io/noseka1/kubernetes-external-secrets:6.3.0-patch1
```

When deploying the External Secrets operator using a [Helm Chart](https://github.com/external-secrets/kubernetes-external-secrets/tree/master/charts/kubernetes-external-secrets), you can leverage the custom image by setting the Chart's `values.yaml` to something like this:

```
image:
	repository: quay.io/noseka1/kubernetes-external-secrets
	tag: 6.3.0-patch1
	pullPolicy: Always
env:
	LOG_LEVEL: debug
	VAULT_ADDR: https://vault-vault.apps.cluster-7d77.sandbox828.opentlc.com
	DEFAULT_VAULT_MOUNT_POINT: kubernetes
	DEFAULT_VAULT_ROLE: external-secrets
	CUSTOM_KUBERNETES_TOKEN_PATH: /mnt/token
filesFromSecret:
	token:
		mountPath: /mnt
		secret: custom-kubernetes-token
```

Helm will deploy you custom External Secrets image. The External Secrets operator will read the Kubernetes authentication token from the file `/mnt/token`.
