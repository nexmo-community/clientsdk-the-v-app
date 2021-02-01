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

const createVonageUser = async (name, display_name) => {
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
    // console.log(err.response.status);
    // console.log(err.response.data);
    // console.log(err.response.data.detail);
    error = err.response.data || err;
  }

  return { vonageUser, error};
}

const getVonageUsers = async (username) => {
  let users;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users?page_size=100`, config);

    if (response && response.data) {
      users = [
        ...response.data._embedded.users.filter(f => f.name !== username)
          .map(m => {
            return {
              vonage_id: m.id,
              name: m.name,
              display_name: m.display_name || m.name
            }
          })
      ]
    }
  }
  catch (err) {
    console.log(err);
  }

  return users;
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

const getVonageConversation = async (conversationId, vonageId) => {
  let conversation;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}`, config);

    if (response && response.data) {
      conversation = buildConversation(response.data, vonageId);
    }
  }
  catch (err) {
    console.log(err);
  }

  return conversation;
}

const buildConversation = async (conversation, vonageId) => {
  let members = await getConversationMembers(conversation.id);
  // let me = members.find(f => f.user_id === vonageId);
  members = members.filter(f => f.user_id !== vonageId);

  const name = members.map(m => m.name).join(', ');

  return {
    uuid: conversation.id,
    name,
    created_at: conversation.timestamp.created || null,
    // invited_at: (me === undefined) ? null : me.timestamp.invited || null,
    // joined_at: (me === undefined) ? null : me.timestamp.joined || null,
    // left_at: (me === undefined) ? null : me.timestamp.left || null,
    users: members
  };
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
  createVonageUser,
  getVonageConversations,
  getVonageUsers
}