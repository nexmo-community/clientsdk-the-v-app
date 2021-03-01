const express = require('express');

const DB = require('../data');
const JWT = require('../jwt');
const Validation = require('../validation');
const Vonage = require('../vonage');

const authRoutes = express.Router();

authRoutes.post('/signup', async (req, res) => {
  const { name, password, display_name } = req.body;

  // validate that they done passed everything in
  const invalid_parameters = Validation.validateSignupParameters(name, password, display_name);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
    return;
  }

  // Check if a Vonage User exists in the local DB
  let user = await DB.users.getByName(name);
  if (user) {
    if(user.password_digest) {
      res.status(409).send({
        "type": "data:validation",
        "title": "Bad Request",
        "detail": "User already exists.",
        "invalid_parameters": [
          {
            "name": "name",
            "reason": "must be unique"
          }
        ]
      });
    } else {
      await DB.users.addPassword(name, password);
      const token = JWT.getUserJWT(user.name, user.vonage_id);
      res.status(201).send({
        user,
        token
      });
    }
    return;
  }

  // Create Vonage User
  const { vonageUser, error } = await Vonage.users.create(name, display_name);

  if (error) {
    if(error.code != 'user:error:duplicate-name') {
      res.status(500).send({
        "type": "system:error",
        "title": "System Failure",
        "detail": error.detail
      });
      return;
    }
    // retrieve all users from Vonage into DB
    await DB.users.sync();
    // find user in DB
    user = await DB.users.getByName(name);
    // console.log(user);
    // no user in the DB - THIS SHOULD NEVER HAPPEN
    if(!user) {
      res.status(500).send({
        "type": "system:error",
        "title": "System Failure",
        "detail": "There was an issue with the database.",
      });
      return
    }
    await DB.users.addPassword(name, password);
    const token = JWT.getUserJWT(user.name, user.vonage_id);
    res.status(201).send({
      user,
      token
    });
    return
  }

  user = await DB.users.create(name, password, display_name, vonageUser.id);

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
      "detail": "User already exists.",
      "invalid_parameters": [
        {
          "name": "name",
          "reason": "must be unique"
        }
      ]
    });
    return;
  }

  // Create JWT
  const token = JWT.getUserJWT(user.name, user.vonage_id);

  res.status(201).send({
    user,
    token
  });
});





authRoutes.post('/login', async (req, res) => {

  const { name, password } = req.body;

  // validate that they done passed everything in
  const invalid_parameters = Validation.validateLoginParameters(name, password);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
    return;
  }

  const user = await DB.users.authenticate(name, password);

  if (!user) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Create JWT
  const token = JWT.getUserJWT(user.name, user.vonage_id);

  res.status(201).send({
    user,
    token
  });
});

module.exports = authRoutes