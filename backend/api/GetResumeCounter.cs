using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.CosmosDB;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Functions.Worker;
using System.Net.Http;
using System.Text;

namespace Company.Function
{
    public static class GetResumeCounter
    {
        [FunctionName("GetResumeCounter")]
        public static async Task<HttpResponseMessage> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            [CosmosDB(databaseName: "AzureResume", containerName: "Counter", Connection = "AzureResumeConnectionString", Id = "1", PartitionKey = "1")] Counter counter,
            [CosmosDB(databaseName: "AzureResume", containerName: "Counter", Connection = "AzureResumeConnectionString")] IAsyncCollector<Counter> counterCollector,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            if (counter == null)
            {
                // If item with ID 1 doesn't exist, then create it with count 1.
                counter = new Counter
                {
                    Id = "1",
                    Count = 1
                };

                await counterCollector.AddAsync(counter);
            }
            else
            {
                counter.Count += 1;
                await counterCollector.AddAsync(counter);
            }

            var jsonToReturn = JsonConvert.SerializeObject(counter);

            return new HttpResponseMessage(System.Net.HttpStatusCode.OK)
            {
                Content = new StringContent(jsonToReturn, Encoding.UTF8, "application/json")
            };
        }
    }
}
