import express from 'express';
import multer from 'multer';

import Storage from '../helpers/storage.js';
import Users from '../helpers/users.js';
import Validation from '../helpers/validation.js';

const userRoutes = express.Router();

const multerStorage = multer.memoryStorage();
const upload = multer({ storage: multerStorage });

const imageUpload = upload.fields(
  [
    { name: 'image', maxCount: 1 },
  ]
);

userRoutes.get('/users', Validation.decodeJWT, async (req, res, next) => {
  try {
    const user = await Storage.getUser(req.userJWT.sub);
    if (!user) {
        res.status(403).send({
            "type": "auth:unauthorized",
            "title": "Bad Request",
            "detail": "The request failed due to invalid credentials"
        });
        return;
    }

    const users = await Storage.getAllUsers();
    res.json(users);
  } catch (e) {
    next(e);
  }
});

userRoutes.post('/users/image', Validation.decodeJWT, imageUpload, async (req, res, next) => {
  try {
    const userId = req.userJWT.user_id;
    const username = req.userJWT.sub;
    const imageFile = req.files.image[0];

    const user = await Storage.getUser(username);
    if (!user) {
        res.status(403).send({
            "type": "auth:unauthorized",
            "title": "Bad Request",
            "detail": "The request failed due to invalid credentials"
        });
        return;
    }

    const imageUrl = await Storage.storeUserImage(userId, imageFile);
    const vonageUser = await Users.updateImage(userId, imageUrl);

    if (vonageUser) {
      await Storage.updateUser(username, imageUrl);
      res.json({ image_url: imageUrl });
      return;
    } else {
      res.status(500).send({
        "type": "internal",
        "title": "Internal Server Error",
        "detail": "The request failed, try again"
    });
    }

  } catch (e) {
    next(e);
  }
});

export default userRoutes;