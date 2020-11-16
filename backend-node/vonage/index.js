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

const getVonageUsers = async (username) => {
  let users;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users?page_size=100`, config);

    if (response && response.data) {
      users = {
        users: [
          ...response.data._embedded.users.filter(f => f.name !== username)
            .map(m => {
              return {
                name: m.display_name || m.name,
                username: m.name,
                user_id: m.id
              }
            })
        ]
      }
    }
  }
  catch (err) {
    console.log(err);
  }

  return users;
}

const getVonageConversations = async (userId) => {
  let conversations = [];

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users/${userId}/conversations`, config);

    if (response && response.data) {
      const lightConversations = response.data._embedded.conversations;
      for (let i = 0; i < lightConversations.length; i++) {
        conversations.push(await getVonageConversation(lightConversations[i].id, userId));
      }
    }
  }
  catch (err) {
    console.log(err);
  }

  return conversations;
}

const getVonageConversation = async (conversationId, userId) => {
  let conversation;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}`, config);

    if (response && response.data) {
      conversation = buildConversation(response.data, userId);
    }
  }
  catch (err) {
    console.log(err);
  }

  return conversation;
}

const buildConversation = async (conversation, userId) => {
  let members = await getConversationMembers(conversation.id);
  // let me = members.find(f => f.user_id === userId);
  members = members.filter(f => f.user_id !== userId);

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

const buildConversations = (conversations, userId) => {
  return {
    conversations: [
      ...conversations.map(async (conversation) => await buildConversation(conversation, userId))
    ]
  }
}

const createVonageConversation = async (userId, usersIds) => {
  let vonageConversation;

  try {

    const body = {};

    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/conversations`, body, config);

    if (response && response.status === 201) {
      let conversation = response.data;

      // Create members for this new conversation
      usersIds.push(userId);
      for (let i = 0; i < usersIds.length; i++) {
        await createMember(conversation.id, usersIds[i]);
      }

      // Send back the convo-mumbo-jumbo
      vonageConversation = await getVonageConversation(conversation.id, userId);
    }
  }
  catch (err) {
    console.log(err);
  }

  return vonageConversation;
}

const createMember = async (conversationId, userId) => {
  let vonageMember;

  try {

    const body = {
      user: {
        id: userId
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