FROM ghcr.io/external-secrets/kubernetes-external-secrets:6.4.0

COPY custom_kubernetes_token_path.diff /tmp
USER root
# Allow External Secrets operator to authenticate against a remote Kubernetes cluster
RUN cd /app && patch -p1 < /tmp/custom_kubernetes_token_path.diff
USER 1000
