$clusterName = "webapps-cluster-1"
$resourceGroup = "webapps-clusters-rg"
$location = "eastus"
$k8sVersion = "1.25.5"
$fleetName = "webapps-fleet"
$definitionFilePath = "~\repos\aks-cluster-orchestration\clusterctl\definitions\aks-standard-3NP.yaml"
$workerMachineCount = 3
$controlPlaneMachineCount = 3
# I have these variabels set as persistent environment variables
# you can opt to do the same or set them during runtime
#
# $env:AZURE_TENANT_ID = "<spn.tenant-id>" 
# $env:AZURE_CLIENT_ID = "<spn.app-id>"
# $env:AZURE_CLIENT_SECRET = "<spn.password>"

# Settings needed for AzureClusterIdentity used by the AzureCluster
$env:AZURE_CLUSTER_IDENTITY_SECRET_NAME="cluster-identity-secret"
$env:CLUSTER_IDENTITY_NAME="cluster-identity"
$env:AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE="default"

# Name of the Azure datacenter location. Change this value to your desired location.
$env:AZURE_LOCATION=$location

# Select VM types.
$env:AZURE_CONTROL_PLANE_MACHINE_TYPE="Standard_D2s_v3"
$env:AZURE_NODE_MACHINE_TYPE="Standard_D2s_v3"

# resource group cluster will be deployed to
# if it doesn't exist it will be created
$env:AZURE_RESOURCE_GROUP=$resourceGroup

# this experimental flag is required for Cluster API
# to leverage the underlying infrastructure provider
# otherwise it will try to create a vanilla k8s cluster
# more details here: https://cluster-api.sigs.k8s.io/tasks/experimental-features/machine-pools.html
$env:EXP_MACHINE_POOL="true"

# optional feature flag for health monitoring
# https://github.com/kubernetes-sigs/cluster-api-provider-azure/blob/main/docs/book/src/topics/managedcluster.md
$env:EXP_AKS_RESOURCE_HEALTH="true"
$env:WORKER_MACHINE_COUNT=$workerMachineCount
$env:CONTROL_PLANE_MACHINE_COUNT=$controlPlaneMachineCount

######## !!! IMPORTANT: Your kubectl context must be set to the capz management cluster !!! ########

# generate cluster definition yaml
Get-Content $definitionFilePath | `
        clusterctl generate cluster $clusterName `
        --kubernetes-version $k8sVersion > $clusterName.yaml

# create the workload cluster
# at this point we assume you've created
# the management cluster
# !!! IMPORTANT: Your kubectl context must be set to the management cluster !!!
kubectl apply -f $clusterName.yaml

# wait for the workload cluster to be ready
kubectl wait cluster -n default $clusterName --for=condition=Ready --timeout=45m

$clusterId = "/subscriptions/$env:AZURE_SUBSCRIPTION_ID/resourceGroups/$env:AZURE_RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$clusterName"

# add cluster to fleet
az fleet member create `
    --fleet-name $fleetName `
    --member-cluster-id $clusterId `
    --name $clusterName `
    --resource-group $resourceGroup
    
