# AKS Cluster Orchestration

Kubernetes is hard, what's even hard is managing a moltitude of clusers, distributing the work, and ensuring all your clusters are healthy. There are several approaches to solving this problem; one of the most popular approaches is using Cluster API to manage your fleet.  In this guide we're going to use Cluster API Azure Provider provision and maintain clusters.  We will also use Azure Fleet to manage workload distribution once those clusters are available.

## Docs

To complete this guide we will use the following documentation:

- [Cluster API Book](https://cluster-api.sigs.k8s.io/user/quick-start.html)
- [Cluster API Provider Azure Book](https://capz.sigs.k8s.io/topics/getting-started.html#prerequisites)
- [Azure Fleet Quickstart](https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-and-members)
- [Azure Fleet Resource Propegation](https://learn.microsoft.com/en-us/azure/kubernetes-fleet/configuration-propagation)

## Prerequisits

- [Azure Account](https://azure.microsoft.com/en-us/free/search/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
- [Azure Service Principal](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
  - [CAPZ](https://capz.sigs.k8s.io/topics/getting-started.html)
 


## Overview

All the infrastructure is defined in the `terraform` folder.  You can modify the names of resources by creating your own `tfvars` file.  The following resources will be created:

- Resource Group
- Fleet Manager
- Networking Resources
- AKS CLuster To be our Cluster Manager
