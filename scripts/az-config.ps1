# create service principal aks-fleet-manager-spn with role contributor
$spn = az ad sp create-for-rbac `
        --name "aks-fleet-manager-spn" `
        --role contributor `
        --scopes /subscriptions/$env:AZURE_SUBSCRIPTION_ID

$env:AZURE_TENANT_ID = $spn.tenant
$env:AZURE_CLIENT_ID = $spn.appId
$env:AZURE_CLIENT_SECRET = $spn.password
