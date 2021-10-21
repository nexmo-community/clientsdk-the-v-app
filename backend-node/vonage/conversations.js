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

const getAll = async () => {
  let vonageConversations;
  let error;
  console.log(`VONAGE: Retrieving conversations`);
  try {
    const config = getConfig(JWT.getAdminJWT());
    await Pagination.paginatedRequest('conversations', `${vonageAPIUrl}/conversations?page_size=100`, config, [], (response) => {
      if (response) {
        vonageConversations = response;
      } else {
        error = "Unexpected error";
      }
    });
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

  try {
    const config = getConfig(JWT.getAdminJWT());
    await Pagination.paginatedRequest('members', `${vonageAPIUrl}/conversations/${conversationId}/members?page_size=100`, config, [], (response) => {
      if (response) {
        vonageMembers = response;
      } else {
        error = "Unexpected error";
      }
    });
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

  try {
    const config = getConfig(JWT.getAdminJWT());
    await Pagination.paginatedRequest('events', `${vonageAPIUrl}/conversations/${conversationId}/events?page_size=100`, config, [], (response) => {
      if (response) {
        vonageEvents = response;
      } else {
        error = "Unexpected error";
      }
    });
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
