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

const createVonageUser = async (username, name) => {
  let vonageUser;

  try {

    const body = {
      name: username,
      display_name: name
    };
    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/users`, body, config);

    if (response && response.status === 201) {
      vonageUser = response.data;
    }

  }
  catch (err) {
    console.log(err);
  }

  return vonageUser;
}

const getVonageUsers = async (jwt) => {
  let users;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users`, config);

    if (response) {
      console.dir(response);
      users = response.body;
    }

  }
  catch (err) {
    console.log(err);
  }

  return users;
}

module.exports = {
  createVonageUser,
  getVonageUsers
}