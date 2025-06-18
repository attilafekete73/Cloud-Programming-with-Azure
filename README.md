# Cloud-Programming-with-Azure

to enable terraform to deploy infrastructure, create a service principal using azure cli:
az login
az ad sp create-for-rbac --name "githubterraformserviceprincipal" --role contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --sdk-auth

and copy the output of the later command as the value to an action secret named AZURE_CREDENTIALS
