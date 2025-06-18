# Cloud-Programming-with-Azure

to enable terraform to deploy infrastructure, create a service principal using azure cli:
az login
az ad sp create-for-rbac --name "githubterraformserviceprincipal" --role contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --sdk-auth

and copy the output of the later command as the value to an action secret named AZURE_CREDENTIALS


#store tfstate in azure
$resourceGroup = "myResourceGroup"
$location = "westeurope"
$storageAccount = "tfstate$((Get-Random -Maximum 99999))"
$containerName = "tfstate"
az group create --name $resourceGroup --location $location
az storage account create --name $storageaccount --resource-group $resourceGroup --location $location --sku Standard_LRS --encryption-services blob
az storage container create --name $containerName --account-name $storageaccount
$accountKey = (az storage account keys list --resource-group $resourceGroup --account-name $storageaccount --query '[0].value' -o tsv)

