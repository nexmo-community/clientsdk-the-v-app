const { json } = require('express');
const express = require('express');

const JWT = require('../helpers/jwt');
const Validation = require('../helpers/validation');
const Storage = require('../helpers/storage');
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

  const user = Storage.getUser(name);

  if (user) {
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
    const { vonageUser, error } = await Vonage.users.create(name, display_name);
    if (error) {

    } else {
      const createdUser = await Storage.createUser(vonageUser.id, name, display_name, password);
      if (!createdUser) {
        // Error creating New User
        res.status(500).send({
          "type": "system:error",
          "title": "System Failure",
          "detail": "There was an issue with the database.",
        });
      } else {
        // New User created successfully
        const token = JWT.getUserJWT(createdUser.name, createdUser.id);
        // let users = await Data.users.getInterlocutorsFor(client, user.name);
        // const conversations = await Data.conversations.getAllForUser(client, user.id);
        jsonResponse = {
          createdUser,
          conversations
        }
        res.status(201).send(jsonResponse);
      }
    }
  }
});

// authRoutes.post('/login', async (req, res) => {
//   const { name, password } = req.body;
//   const invalid_parameters = Validation.validateLoginParameters(name, password);
//   if (invalid_parameters.length > 0) {
//     res.status(400).send({
//       "type": "data:validation",
//       "title": "Bad Request",
//       "detail": "The request failed due to validation errors",
//       invalid_parameters
//     });
//     return;
//   }

//   const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
//   pool.connect(async (err, client, done) => {
//     if (err) throw err
//     const user = await Data.users.authenticate(client, name, password);

//     if (!user) {
//       res.status(403).send({
//         "type": "auth:unauthorized",
//         "title": "Bad Request",
//         "detail": "The request failed due to invalid credentials"
//       });
//     } else {
//       user.id = user.vonage_id;
//       delete user.vonage_id;
//       const token = JWT.getUserJWT(user.name, user.id);
//       let users = await Data.users.getInterlocutorsFor(client, user.name);
//       const conversations = await Data.conversations.getAllForUser(client, user.id, true);
//       jsonResponse = {
//         user,
//         token,
//         users,
//         conversations
//       }
//       console.log(jsonResponse);
//       res.status(200).send(jsonResponse);
//     }
//     client.release();
//   });
//   pool.end();
// });

const signupCreateVonageUserError = async function(res, client, error, name, password) {
  // return any error apart from user name duplicate
  if(error.code != 'user:error:duplicate-name') {
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": error.detail
    });
    return;
  }
  // find local user
  user = await Data.users.getByName(client, name);
  // no local user - THIS SHOULD NEVER HAPPEN
  if(!user) {
    res.status(500).send({
      "type": "system:error",
      "title": "System Failure",
      "detail": "There was an issue with the database.",
    });
    return
  }
  user.id = user.vonage_id;
  delete user.vonage_id;
  // The user existed on the Vonage server - we'll add the password
  await Data.users.addPassword(client, name, password);
  const token = JWT.getUserJWT(user.name, user.id);
  res.status(201).send({
    user,
    token
  });
};

module.exports = authRoutes