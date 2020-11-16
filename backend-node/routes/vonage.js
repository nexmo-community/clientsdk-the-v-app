const express = require('express');
const jwt = require('express-jwt');
const fs = require('fs');
const Vonage = require('../vonage');

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

  if (jwt) {
    const vonageUsers = await Vonage.getVonageUsers(req.user.name);
    res.status(200).json(vonageUsers);
  }

  res.status(200);
});

vonageRoutes.get('/conversations', async (req, res) => {

  const jwt = fromHeaderOrQuerystring(req);

  if (jwt) {
    const vonageConversations = await Vonage.getVonageConversations(req.user.user_id);
    res.status(200).json(vonageConversations);
  }

  res.status(200);
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