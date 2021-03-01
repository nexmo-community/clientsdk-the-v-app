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

const private_key = fs.readFileSync('./private.key', { encoding: 'utf8', flag: 'r' });

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
  let vonageUsers = await Data.users.getAll();
  vonageUsers = vonageUsers.filter(f => f.name !== req.user.sub)
  res.status(200).json(vonageUsers);
});

vonageRoutes.get('/conversations', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403);
  }
  const vonageConversations = await Data.conversations.getAllForUser(req.user.user_id);
  res.status(200).json(vonageConversations);
});

vonageRoutes.post('/conversations', async (req, res) => {

  const jwt = fromHeaderOrQuerystring(req);
  const users = req.body.users;

  if (jwt && users && users.length > 0) {
    const vonageConversation = await Vonage.createVonageConversation(req.user.user_id, users);
    res.status(200).json(vonageConversation);
  }

  res.status(200);
});

module.exports = vonageRoutes