const express = require('express');
const { Pool } = require('pg');
const jwt = require('express-jwt');
const Data = require('../data');
const aws = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const Vonage = require('../vonage');
var path = require('path');

const vonageRoutes = express.Router();

aws.config.update({
  secretAccessKey: process.env.awsAccessSecret,
  accessKeyId: process.env.awsAccessKey,
  region: process.env.awsRegion
});

const s3 = new aws.S3();

const fromHeaderOrQuerystring = (req) => {
  if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
    return req.headers.authorization.split(' ')[1];
  } else if (req.query && req.query.token) {
    return req.query.token;
  }
  return null;
}

const uploadImage = multer({
  storage: multerS3({
      s3: s3,
      bucket: process.env.awsBucketName,
      key: function (req, file, cb) {
          const extensionArray = file.mimetype.split("/");
          const extension = extensionArray[extensionArray.length - 1];
          const filename = Date.now().toString() + '.' + extension;
          cb(null, filename);
      }
  })
});

function authUser(req, res, next) {
  const jwt = fromHeaderOrQuerystring(req);
  if (!jwt || !req.user || !req.user.user_id) {
    return res.status(403).json("Unauthorised");
  }
  next();
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
    return res.status(200).json(users);
    client.release();
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
    const vonageConversations = await Data.conversations.getAllForUser(client, req.user.user_id);
    return res.status(200).json(vonageConversations);
    client.release();
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

vonageRoutes.post('/image', authUser, uploadImage.single('image'), async (req, res) => {
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    const user = await Data.users.getByVonageId(client, req.user.user_id)
    if (user.image_url) {
      // If the user already has an image delete it from S3
      const filename = path.basename(user.image_url);
      const params = {
        Bucket: process.env.awsBucketName,
        Key: filename
      }   
      s3.deleteObject(params, function(err, data) {
        if (err) console.log(err, err.stack);
        else console.log('delete', data);
      });
    }

    // Set the new image
    await Data.users.addImage(client, user.name, req.file.location)

    client.release();
  });

  // upload the image to vonage
  const imageResponse = await Vonage.users.addImage(req.user.user_id, req.file.location);
  
  if (imageResponse.responseId) {
    res.status(200).json({'image_url': req.file.location});
  } else {
    res.status(500).json("ERROR");
  }
});

module.exports = vonageRoutes