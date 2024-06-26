import express from 'express';

import Validation from '../helpers/validation.js';
import Storage from '../helpers/storage.js';
import Users from '../helpers/users.js';
import JWT from '../helpers/jwt.js';

const authRoutes = express.Router();

authRoutes.post('/signup', Validation.validateSignupParameters, async (req, res) => {
  const { name, password, display_name } = req.body;

  // Check if user exists
  const storedUser = await Storage.getUser(name);
  if (storedUser) {
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

  // Create Vonage user
  const { vonageUser, error } = await Users.create(name, display_name);
  if (error) {
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": error.detail
    });
    return;
  }

  // Store user
  const user = await Storage.storeUser(vonageUser.id, name, display_name, password);
  if (!user) {
    // Error creating New User
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": "There was an issue with the database.",
    });
    return;
  }

  // New User created successfully
  const jsonResponse = await authJSONResponse(user);
  res.status(201).json(jsonResponse);

});

authRoutes.post('/login', Validation.validateLoginParameters, async (req, res) => {
  const { name, password } = req.body;

  // Check if user exists
  const storedUser = await Storage.getUser(name);
  if (!storedUser) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Authenticate user
  const authenticatedUser = await Storage.authUser(storedUser, password);
  if (!authenticatedUser) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Login successful
  const jsonResponse = await authJSONResponse(authenticatedUser);
  res.status(200).send(jsonResponse);
});

authRoutes.post('/token', Validation.validateLoginParameters, async (req, res) => {
  const { name, password } = req.body;

  // Check if user exists
  const storedUser = await Storage.getUser(name);
  if (!storedUser) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Authenticate user
  const authenticatedUser = await Storage.authUser(storedUser, password);
  if (!authenticatedUser) {
    res.status(403).send({
      "type": "auth:unauthorized",
      "title": "Bad Request",
      "detail": "The request failed due to invalid credentials"
    });
    return;
  }

  // Refresh successful
  const token = JWT.getUserJWT(authenticatedUser.name, authenticatedUser.id);
  res.status(200).send({ token: token });
});

async function authJSONResponse(user) {
  const token = JWT.getUserJWT(user.name, user.id);
  const users = await Storage.getAllUsers();

  const currentUserIndex = users.findIndex(u => u.id === user.id);

  if (currentUserIndex !== -1) {
    users.splice(currentUserIndex, 1);
  }

  return {
    user,
    users,
    token
  }
}

export default authRoutes;