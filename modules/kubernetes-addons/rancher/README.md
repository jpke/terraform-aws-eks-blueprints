# Rancher IAM User

Creates an IAM user with permission to manage EKS clusters. Used to provision EKS clusters through Rancher. Contains the [minimum permissions](https://rancher.com/docs/rancher/v2.5/en/cluster-provisioning/hosted-kubernetes-clusters/eks/permissions/) required.

Stores IAM User creds in AWS Secrets Manager.
