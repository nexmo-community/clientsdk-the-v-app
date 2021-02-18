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

const getVonageConversations = async (vonageId) => {
  let conversations = [];

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users/${vonageId}/conversations`, config);

    if (response && response.data) {
      const lightConversations = response.data._embedded.conversations;
      for (let i = 0; i < lightConversations.length; i++) {
        conversations.push(await getVonageConversation(lightConversations[i].id, vonageId));
      }
    }
  }
  catch (err) {
    console.log(err);
  }

  return conversations;
}


const buildConversations = (conversations, vonageId) => {
  return {
    conversations: [
      ...conversations.map(async (conversation) => await buildConversation(conversation, vonageId))
    ]
  }
}

const createVonageConversation = async (vonageId, usersIds) => {
  let vonageConversation;

  try {

    const body = {};

    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/conversations`, body, config);

    if (response && response.status === 201) {
      let conversation = response.data;

      // Create members for this new conversation
      usersIds.push(vonageId);
      for (let i = 0; i < usersIds.length; i++) {
        await createMember(conversation.id, usersIds[i]);
      }

      // Send back the convo-mumbo-jumbo
      vonageConversation = await getVonageConversation(conversation.id, vonageId);
    }
  }
  catch (err) {
    console.log(err);
  }

  return vonageConversation;
}

const createMember = async (conversationId, vonageId) => {
  let vonageMember;

  try {

    const body = {
      user: {
        id: vonageId
      },
      channel: {
        type: 'app'
      },
      state: 'joined'
    };

    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/conversations/${conversationId}/members`, body, config);

    if (response && response.status === 201) {
      vonageMember = {
        name: response.data._embedded.user.display_name || response.data._embedded.user.name,
        username: response.data._embedded.user.name,
        state: response.data.state
      };
    }

  }
  catch (err) {
    console.log(err);
  }

  return vonageMember;
}


const getConversationMembers = async (conversationId) => {
  let members;

  try {
    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}/members`, config);

    if (response && response.data) {
      members = response.data._embedded.members.map(m => {
        return {
          name: m._embedded.user.display_name || m._embedded.user.name,
          username: m._embedded.user.name,
          user_id: m._embedded.user.id,
          state: m.state
        };
      });
    }
  }
  catch (err) {
    console.log(err);
  }

  return members;
}

module.exports = {
  createVonageConversation,
  getVonageConversations
}




const users = require('./users');
const conversations = require('./conversations');
const members = require('./members');

module.exports = {
  users,
  conversations,
  members
}