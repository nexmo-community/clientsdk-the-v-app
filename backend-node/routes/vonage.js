const express = require('express');
const { Pool } = require('pg');
const jwt = require('express-jwt');
const Data = require('../data');
const Vonage = require('../vonage');
var path = require('path');

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
    return res.status(403).json("Unauthorised");
  }
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    let users = await Data.users.getInterlocutorsFor(client, req.user.sub);
    client.release();
    return res.status(200).json(users);
  });
  pool.end();
});

vonageRoutes.get('/conversations', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403).json("Unauthorised");
  }
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    const vonageConversations = await Data.conversations.getAllForUser(client, req.user.user_id, true);
    client.release();
    return res.status(200).json(vonageConversations);
  });
  pool.end();
});

vonageRoutes.get('/conversations/:id', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403).json("Unauthorised");
  }
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    const vonageConversation = await Data.conversations.getConversationForUser(client, req.params.id, req.user.user_id);
    if(vonageConversation) {
      res.status(200).json(vonageConversation);
    } else {
      res.status(500).json({message: 'something went wrong'});
    }
    client.release();
  });
  pool.end();
});

vonageRoutes.post('/conversations', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403).json("Unauthorised");
  }
  const users = req.body.users;
  if (!users || users.length == 0) {
    return res.status(400).json({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request must include users"
    });
  }
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    const vonageConversation = await Data.conversations.createConversationForUserWithInterlocutors(client, req.user.user_id, users);
    if(vonageConversation) {
      res.status(200).json(vonageConversation);
    } else {
      res.status(500).json("ERROR");
    }
    client.release();
  });
  pool.end();
});

vonageRoutes.post('/image', async (req, res) => {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.sub) {
    return res.status(403).json("Unauthorised");
  }
   
  if (!req.body.image_url) {
    return res.status(400).json({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request must include image_url"
    });
  }
    
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err

  // Set the image on the DB
    await Data.users.addImage(client, req.user.sub, req.body.image_url)
  });

  // Upload the image to vonage
  const imageResponse = await Vonage.users.addImage(req.user.user_id, req.body.image_url);
  
  if (imageResponse.responseId) {
    res.status(200).json({'image_url': req.body.image_url});
  } else {
    res.status(500).json("ERROR");
  }
});

module.exports = vonageRoutes