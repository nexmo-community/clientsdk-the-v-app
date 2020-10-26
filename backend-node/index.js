const { json } = require('express');
const express = require('express');
const app = express();
const port = 3000;

const DB = require('./database');
const Validation = require('./validation');

app.use(express.json());

app.post('/signup', async (req, res) => {
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

  const user = await DB.createUser(username, password, name);

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
  const token = {};



  res.status(201).send({
    user,
    token
  });
});

app.post('/login', async (req, res) => {

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
  const token = {};

  res.status(201).send({
    user,
    token
  });
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});

