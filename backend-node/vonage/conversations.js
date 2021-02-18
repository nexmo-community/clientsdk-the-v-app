const axios = require('axios');
const JWT = require('../jwt');
const vonageAPIUrl = 'https://api.nexmo.com/v0.3';


const getConfig = (jwt) => {
  return {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${jwt}`
    }
  };
}


const get = async (conversationId) => {
  let vonageConversation;
  let error;
  console.log(`VONAGE: Retrieving conversation ${JSON.stringify(conversationId)}`);
  try {
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}`, config);
    if (response && response.status === 200) {
      vonageConversation = response.data;
    } else {
      error = "Unexpected error";
    }
  }
  catch (err) {
    if (err && err.response) {
      error = err.response.data;
    } else {
      error = err;
    }
  }
  return { vonageConversation, error};
}



module.exports = {
  get
}
