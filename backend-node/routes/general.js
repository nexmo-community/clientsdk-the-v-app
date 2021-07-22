const express = require('express');

const generalRoutes = express.Router();

generalRoutes.get('/ping', async (req, res) => {
  res.status(200).send({
    message: 'All good'
  });
});

module.exports = generalRoutes;