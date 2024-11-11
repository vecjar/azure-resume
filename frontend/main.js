window.addEventListener('DOMContentLoaded', (event) => {
    getVisitCount();
})

const functionApiUrl = 'https://func-azurecloudresume-api-b2tc.azurewebsites.net/api/GetResumeCounterjv88?code=DwyC5OyAPNo_mOKVBVXxk18HOCwIqKfKkDwmYDWQK5-qAzFu3RYqtw%3D%3D'
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