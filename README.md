# Cloud-Programming-with-Azure

This is a demo app for a university project in cloud programming. I hosted a simple webpage on Azure, considering that it had to be highly-available, it had to autoscale and visitors from all around the world don't experience latency. 
For these purposes, I have built my architecture with three app services, and a geographic-based traffic manager which connects them to their respective regions: East US 2 (AMER), Southeast Asia (APAC), West Europe (EMEA). All of these app services have built-in autoscale, which will scale them every minute based on the average CPU percentage of the last five minutes. 
For testing purposes, I made the visual part of the website in such a way that it shows the latency with a press of a button, it shows the country the user is in and it also shows which app service is serving the website at the moment (EU/AS/US)

# setting it up for yourself

First, to enable terraform to deploy infrastructure, you need to create a service principal using cloud shell (PowerShell):

```
az ad sp create-for-rbac --name "github-action-sp" --role contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --sdk-auth
```

and copy the output of the later command as the value to an action secret named AZURE_CREDENTIALS

Then you also need to store your tfstate file in azure, and you need to store its output as an action secret named AZURE_TFSTATE_STORAGE_ACCOUNT_KEY

```
$resourceGroup = "tfstate"
$location = "westeurope"
$storageAccount = "tfstate3628800"
$containerName = "tfstate"
az group create --name $resourceGroup --location $location
az storage account create --name $storageaccount --resource-group $resourceGroup --location $location --sku Standard_LRS --encryption-services blob
az storage container create --name $containerName --account-name $storageaccount
$accountKey = (az storage account keys list --resource-group $resourceGroup --account-name $storageaccount --query '[0].value' -o tsv)
$accountKey
```

Then you just need to go to https://github.com/settings/personal-access-tokens to create a fine-grained GitHub access token. You need to select: Administration (Read and write), Codespace Secrets (Read and write), Contents (Read and write), Secrets (Read-only), and Webhooks (Read and write). Then you need to save the access token generated to an action secret named GH_ACCESS_TOKEN

You also need to save your Azure subscription ID in an action variable named AZURE_SUBSCRIPTION_ID

To launch the project, first launch the "Deploy Terraform to Azure Apply" and then launch the "Build and Deploy PHP app to Azure Web App" (if either one would give you an error, just run it again, it will probably be because the instance couldn't be set up correctly for the first time). If you get a 409 error for o ne of the app services, just go to the terraform file of the region that gave the error and change the region to another one in the 7th line. 

Then before you are done, you have to do one more thing in the cloud shell:
```
az webapp config hostname add --resource-group webapp-rg-asia --webapp-name cloudprogrammingproject-3628800-as --hostname mygeoapp.trafficmanager.net
az webapp config hostname add --resource-group webapp-rg-eu --webapp-name cloudprogrammingproject-3628800-eu --hostname mygeoapp.trafficmanager.net
az webapp config hostname add --resource-group webapp-rg-us --webapp-name cloudprogrammingproject-3628800-us --hostname mygeoapp.trafficmanager.net
```

Then, you just go to the website defined by your trafficmanager (if you don't change anything in the code, it is called mygeoapp.trafficmanager.net) and ENJOY!
