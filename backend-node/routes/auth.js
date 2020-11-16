const express = require('express');

const DB = require('../data');
const JWT = require('../jwt');
const Validation = require('../validation');
const Vonage = require('../vonage');

const authRoutes = express.Router();

authRoutes.post('/signup', async (req, res) => {
  const { username, password, name } = req.body;

  // validate that they done passed everything in
  const invalid_parameters = Validation.validateSignupParameters(username, password, name);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
    return;
  }

  // Create Vonage User
  const vonageUser = await Vonage.createVonageUser(username, name);

  if (!vonageUser) {
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": "There was an issue with the Vonage API.",
    });
    return;
  }

  const user = await DB.createUser(username, password, name, vonageUser.id);

  if (!user) {
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": "There was an issue with the database.",
    });
    return;
  }

  if (user.status === 'existed') {
    res.status(409).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "Username already exists.",
      "invalid_parameters": [
        {
          "name": "username",
          "reason": "must be unique"
        }
      ]
    });
    return;
  }

  // Create JWT
  const token = JWT.getUserJWT(user.username, user.userid);

  res.status(201).send({
    user,
    token
  });
});

authRoutes.post('/login', async (req, res) => {

  const { username, password } = req.body;

  // validate that they done passed everything in
  const invalid_parameters = Validation.validateLoginParameters(username, password);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
    return;
  }

  const user = await DB.identifyUser(username, password);

  if (!user) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Create JWT
  const token = JWT.getUserJWT(user.username, user.userId);

  res.status(201).send({
    user,
    token
  });
});

module.exports = authRoutes