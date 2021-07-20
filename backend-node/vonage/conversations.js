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

const getAll = async () => {
  let vonageConversations;
  let error;
  console.log(`VONAGE: Retrieving conversations`);
  try {
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations?page_size=100`, config);
    if (response && response.status === 200 && response.data && response.data._embedded) {
      vonageConversations = response.data._embedded.conversations;
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
  return { vonageConversations, error};
}

const get = async (conversationId) => {
  let vonageConversation;
  let error;
  // console.log(`VONAGE: Retrieving conversation ${JSON.stringify(conversationId)}`);
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


const create = async (ownerId, usersIds) => {
  let vonageConversation;
  try {
    const body = {};
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.post(`${vonageAPIUrl}/conversations`, body, config);
    if (response && response.status === 201) {
      vonageConversation = response.data;
    }
  }
  catch (err) {
    console.log(err);
  }
  return vonageConversation;
}



const getMembers = async (conversationId) => {
  let vonageMembers;
  let error;
  // console.log(`VONAGE: Retrieving conversation members ${JSON.stringify(conversationId)}`);
  try {
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}/members`, config);
    if (response && response.status === 200 && response.data && response.data._embedded) {
      vonageMembers = response.data._embedded.members;
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
  return { vonageMembers, error};
}

const createMember = async (conversationId, userId) => {
  let vonageMember;
  try {
    const body = {
      state: 'joined',
      user: {
        id: userId
      },
      channel: {
        type: 'app'
      }
    };
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.post(`${vonageAPIUrl}/conversations/${conversationId}/members`, body, config);
    if (response && response.status === 201) {
      vonageMember = response.data;
    }
  }
  catch (err) {
    console.log(err);
  }
  return vonageMember;
}

const getEvents = async (conversationId) => {
  let vonageEvents;
  let error;
  // console.log(`VONAGE: Retrieving conversation events ${JSON.stringify(conversationId)}`);
  try {
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}/events`, config);
    if (response && response.status === 200 && response.data && response.data._embedded) {
      vonageEvents = response.data._embedded.events;
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
  return { vonageEvents, error};
}


module.exports = {
  getAll,
  get,
  create,
  getMembers,
  createMember,
  getEvents
}
