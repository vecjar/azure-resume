# Cloud resume in Azure
For my implementation of the Cloud Resume Challenge in Azure, I set out to create a static resume website hosted on Azure Blob Storage. The project required integrating several Azure services, including an Azure Function to handle the visitor counter, which interacts with a CosmosDB to store and update visitor data. To enhance the site’s performance and security, I configured Azure CDN to enable HTTPS and a custom domain, alongside setting up Azure DNS for domain management.

To streamline the deployment process, I built a fully automated CI/CD pipeline with Azure DevOps, ensuring effortless updates to the website in the future. The entire infrastructure, including the website and services, was provisioned using Bicep.

This project gave me the opportunity to deepen my experience with a variety of Azure resources, some of which were new to me and others that I had previously worked with as a Junior Cloud Consultant. By leveraging Bicep to provision the necessary services and connecting the front and back ends to Azure DevOps Pipelines, I achieved my goal of creating a semi automated and scalable solution for hosting my Azure resume.

# Components
Frontend:
- A nice looking static website template that I customized to fit my needs.
- Visitor counter: Javascript code in main.js that triggers an Azure Function

Backend:
- Azure CosmosDB database to store visitor counter data
- Azure Functions binded to CosmosDB, to get and update the visitor counter data, written in C#.
- Static website hosting in a blob storage.
- Azure CDN to enable custom domain and https
- Azure DNS to host my custom domain in Azure and to add CNAME records.

CI/CD with Azure Devops:
- Frontend workflow: Changes in website code and they are pushed to Azure Devops repository -> Azure Devops Pipeline updates the website files in Azure blob storage
- Infrastructure workflow: Inital deployment of infrastructure using Bicep
