const express = require('express');
const jwt = require('express-jwt');
const jsonwebtoken = require('jsonwebtoken');
const fs = require('fs');
const Data = require('../data');

const vonageRoutes = express.Router();

const fromHeaderOrQuerystring = (req) => {
  if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
    return req.headers.authorization.split(' ')[1];
  } else if (req.query && req.query.token) {
    return req.query.token;
  }
  return null;
}

const private_key = process.env.vonageAppPrivateKey;

vonageRoutes.use(jwt({
  secret: private_key,
  algorithms: ['RS256'],
  credentialsRequired: false,
  getToken: fromHeaderOrQuerystring
}));

vonageRoutes.get('/users', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.sub) {
    return res.status(403);
  }
  let users = await Data.users.getInterlocutorsFor(req.user.sub);
  return res.status(200).json(users);
});

vonageRoutes.get('/conversations', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403);
  }
  const vonageConversations = await Data.conversations.getAllForUser(req.user.user_id);
  return res.status(200).json(vonageConversations);
});

vonageRoutes.get('/conversations/:id', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403);
  }
  const vonageConversation = await Data.conversations.getConversationForUser(req.params.id, req.user.user_id);
  if(vonageConversation) {
    return res.status(200).json(vonageConversation);
  } else {
    return res.status(500);
  }
});

vonageRoutes.post('/conversations', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403);
  }
  const users = req.body.users;
  if (!users || users.length == 0) {
    return res.status(400);
  }
  const vonageConversation = await Data.conversations.createConversationForUserWithInterlocutors(req.user.user_id, users);

  if(vonageConversation) {
    return res.status(200).json(vonageConversation);
  } else {
    return res.status(500).json("ERROR");
  }
});

module.exports = vonageRoutes