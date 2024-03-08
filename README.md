# ek8s-tools

a proposed shared docker image that is meant to be built and pushed to a registry, and then pulled locally to keep a consistent development/operational environment between shared team members.

Intended usage:
```
./run

# when used with kubectl to launch as a pod on a cluster, consider using an IAM role with temporary credentials and/or IRSA
```
