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
                username: m.name
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
  let conversations;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/users/${userId}/conversations`, config);

    if (response && response.data) {
      conversations = await buildConversations(response.data._embedded.conversations, userId);
    }
  }
  catch (err) {
    console.log(err);
  }

  return conversations;
}

const buildConversations = async (conversations, userId) => {
  return {
    conversations: [
      ...conversations.map(conversation => {
        let users = await getConversationMembers(conversation.id);
        const me = users.find(f => f.user_id === userId);
        users = users.filter(f => f.user_id !== userId);

        const name = users.map(m => m.name).join(', ');

        return {
          uuid: conversation.id,
          name,
          created_at: conversation.timestamp.created || null,
          // invited_at: conversation.timestamp.created || null,
          // joined_at: conversation.timestamp.created || null,
          // left_at: conversation.timestamp.created || null,
          users
        }
      })
    ]
  }
}

const getConversationMembers = (conversationId) => {
  let members;

  try {

    const config = getConfig(JWT.getAdminJWT());
    const response = await axios.get(`${vonageAPIUrl}/conversations/${conversationId}/members`, config);

    if (response && response.data) {
      members = response.data._embedded.members.map(m => {
        return {
          name: m.display_name,
          username: m.name,
          user_id: m.user_id
        };
      });
    }
  }
  catch (err) {
    console.log(err);
  }

  return members;
}

const createVonageConversation = async (userId, usersIds) => {
  let vonageConversation;

  try {

    const body = {};

    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/conversations`, body, config);

    if (response && response.status === 201) {
      // Create members for this new conversation


      // Send back the convo-mumbo-jumbo
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
      user_id: userId,
      action: 'join'
    };

    const config = getConfig(JWT.getAdminJWT());

    const response = await axios.post(`${vonageAPIUrl}/conversations/${conversationId}/members`, body, config);

    if (response && response.status === 201) {
      console.dir(response.data);
      vonageMember = response.data.map(m => {
        return {
          name: "Bob",
          username: "bob",
          state: "joined"
        };
      })
    }

  }
  catch (err) {
    console.log(err);
  }

  return vonageMember;
}

module.exports = {
  createVonageConversation,
  createVonageUser,
  getVonageConversations,
  getVonageUsers
}