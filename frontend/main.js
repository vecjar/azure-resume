window.addEventListener('DOMContentLoaded', (event) => {
    getVisitCount();
})

const functionApiUrl = 'https://azureresumefuncjv.azurewebsites.net/api/GetResumeCounter?code=AB74dY_Fj8Ugw8dmk9CLDKNy39POpyW4eYGlGOW9_N5FAzFu1Angrw%3D%3D'

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