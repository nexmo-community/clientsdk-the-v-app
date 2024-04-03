import express from 'express';

import Storage from '../helpers/storage.js';

const userRoutes = express.Router();

userRoutes.get('/users', async (req, res) => {
  res.json(await Storage.getAllUsers());
});

export default userRoutes;