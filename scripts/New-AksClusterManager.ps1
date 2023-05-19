$resourceGroup = "fleet-orchestration-rg"
# I have these variabels set as persistent environment variables
# you can opt to do the same or set them during runtime
#
# $env:AZURE_TENANT_ID = "<spn.tenant-id>" 
# $env:AZURE_CLIENT_ID = "<spn.app-id>"
# $env:AZURE_CLIENT_SECRET = "<spn.password>"

# Settings needed for AzureClusterIdentity used by the AzureCluster
$env:AZURE_CLUSTER_IDENTITY_SECRET_NAME = "cluster-identity-secret"
$env:CLUSTER_IDENTITY_NAME = "cluster-identity"
$env:AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE = "default"

# Name of the Azure datacenter location. Change this value to your desired location.
ls 

# Select VM types.
$env:AZURE_CONTROL_PLANE_MACHINE_TYPE = "Standard_D2s_v3"
$env:AZURE_NODE_MACHINE_TYPE = "Standard_D2s_v3"

# resource group cluster will be deployed to
# if it doesn't exist it will be created
$env:AZURE_RESOURCE_GROUP = $resourceGroup

# this experimental flag is required for Cluster API
# to leverage the underlying infrastructure provider
# otherwise it will try to create a vanilla k8s cluster
# more details here: https://cluster-api.sigs.k8s.io/tasks/experimental-features/machine-pools.html
$env:EXP_MACHINE_POOL = "true"

# optional feature flag for health monitoring
# https://github.com/kubernetes-sigs/cluster-api-provider-azure/blob/main/docs/book/src/topics/managedcluster.md
$env:EXP_AKS_RESOURCE_HEALTH = "true"
$env:WORKER_MACHINE_COUNT = 2


######## !!! IMPORTANT: Your kubectl context must be set to the capz management cluster !!! ########

# configure the selected cluster as the managemtn cluster
# this will deploy cluster api for azure components to the cluster
kubectl create secret generic `
    $env:AZURE_CLUSTER_IDENTITY_SECRET_NAME `
    --from-literal=clientSecret=$env:AZURE_CLIENT_SECRET `
    --namespace $env:AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE

# Create management cluster
clusterctl init --infrastructure azure
