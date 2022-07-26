const axios = require('axios');
const JWT = require('../jwt');
const Pagination = require('./pagination');
const vonageAPIUrl = 'https://api.nexmo.com/v0.3';

const getConfig = (jwt) => {
  return {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${jwt}`
    }
  };
}

const create = async (name, display_name) => {
  let vonageUser;
  let error;

  try {
    const body = { name, display_name };
    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/users`, body, config);

    if (response) {
      if(response.status === 201) {
        vonageUser = response.data;
      } else {
        error = "Unexpected error";
      }
    }

  }
  catch (err) {
    error = err.response.data || err;
  }

  return { vonageUser, error};
}

const addImage = async (user_id, image_url) => {
  let responseId;
  let error;

  try {
    const body = { image_url };
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.patch(`${vonageAPIUrl}/users/${user_id}`, body, config);
    console.log(response);
    if (response && response.data) {
        responseId = response.data.id;
    } else {
      error = "Unexpected error";
    }
  }
  catch (err) {
    error = err.response.data || err;
  }
  
  return { responseId, error };
}

const getAll = async () => {
  let users;
  try {
    const config = getConfig(JWT.getAdminJWT());
    await Pagination.paginatedRequest('users', `${vonageAPIUrl}/users?page_size=100`, config, [], (response) => {
      if (response) {
        users = [
          ...response.map(m => {
            return {
              vonage_id: m.id,
              name: m.name,
              display_name: m.display_name || m.name
            }
          })
        ]
      }
    });
  }
  catch (err) {
    console.log(err);
  }
  return users;
}

module.exports = {
  create,
  addImage,
  getAll
}