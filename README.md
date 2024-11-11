# Cloud resume in Azure
My implementation of Cloud resume challenge, in Azure. The goal was to build a static resume website that is hosted in Azure blob storage; implement a visitor counter that uses Azure Functions to get and update visitor counter data stored in CosmosDB database; use Azure CDN to enable https and custom domain; build a CI/CD pipeline with Github Actions to make the website publishing effortless. I also Azure DNS to manage custom domain and built the whole Azure infrastructure and most of their configurations with Bicep.

My main goals were to get hands-on experience with various Azure resources, their configuration, deploying those resources with IaC, learn Bicep, and get experience in building a CI/CD pipeline.

# Components
Frontend:
- A nice looking static website template by ceevee that I customized to fit my needs.
- Visitor counter: Javascript code in main.js that triggers an Azure Function

Backend:
- Azure CosmosDB database to store visitor counter data
- Azure Functions binded to CosmosDB, to get and update the visitor counter data. Code in C#, originally by madebygps. I made some changes to the code as I'm provisioning Azure resources with Bicep -> now Functions code adds a count item to the database container after it is provisioned.
- Static website hosting in a blob storage.
- Managed identities to allow resources to access deployment script that enables static website hosting in a storage account
- Azure CDN to enable custom domain and https
- Azure DNS to host my custom domain in Azure and to add CNAME records.

CI/CD with GitHub Actions:
- Frontend workflow: Changes in website code and they are pushed to GitHub repository -> GitHub Actions updates the website files in Azure blob storage
- Backend workflow: Changes in the visitor counter code and changes are pushed to GitHub repository -> GitHub Actions updates the Azure Function
- Infrastructure workflow: manual triggered workflow to deploy Azure infrastructure resources

# Deployment
az group create --name azure-cloud-resume-rg --location australiaeast
az deployment group create --resource-group azure-cloud-resume-rg --template-file ./main.bicep --parameters ./parameters.bicepparam

# Post Manual Deployments
Create Cosmos DB item id: 1 and count: 0 in json
Set Function App enviroment variable = AzureResumeConnectionString = {cosmosdb key}
Enable CORS in Function App and add https://jv.azureedge.net to Allowed Origens
Set const functionApiUrl in main.js to the Function URL before deploying static website
