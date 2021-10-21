const axios = require('axios');

/*
This function uses recursion to handle paginated endpoints.
Key       - The name of the object from the Vonage API endpoint,
            for listing conversations it is 'conversation'.
URL       - The Vonage API endpoint URL 
Config    - The request config, usually headers and an auth token.
Result    - An array of the request results that gets passed between
            recursive calls.
Callback  - A function that gets called when there are no more results.

When a request from the Vonage API returns, the local copy of result
gets appended with the data from the request. Then the `next` object
under `_links` is checked. If it is not null this means that there
are more pages to fetch. If this is the case it calls the function again,
passing in the local copy of result. Then the cycle repeats until `next`
is null which means there are no more pages and the callback function is called.
*/

const paginatedRequest = async (key, url, config, result, callback) => {
    let localResult = result;
    let apiResponse = await axios.get(url, config);
  
    if (apiResponse && apiResponse.status === 200 && apiResponse.data) {
      if (localResult.length === 0) {
        localResult = apiResponse.data._embedded[key];
      } else {
        localResult = [...localResult, ...apiResponse.data._embedded[key]];
      }
      if (apiResponse.data._links.next) {
        await paginatedRequest(key, apiResponse.data._links.next.href, config, localResult, callback);
      } else {
        callback(localResult);
      }
    } else {
      return "Unexpected error";
    }
}

module.exports = {
    paginatedRequest
}