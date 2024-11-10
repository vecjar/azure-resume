window.addEventListener('DOMContentLoaded', (event) => {
    getVisitCount();
})

const functionApiUrl = 'https://getresumecounterjv.azurewebsites.net/api/GetResumeCounter?code=QRcxdI-NIVt8lLDo4CKSve2r0OVM_fCXaof2b0nDIBA1AzFuMGHo_A%3D%3D'
const localFunctionApi = 'http://localhost:7071/api/GetResumeCounter'

const getVisitCount = () => {
    let count = 10;
    fetch(functionApiUrl).then(response => {
        return response.json()
    }).then(response => {
        console.log("Website called function API");
        count = response.count;
        document.getElementById("counter").innerText = count;
    }).catch(function(error){
        console.log(error);
    });
    return count;
}