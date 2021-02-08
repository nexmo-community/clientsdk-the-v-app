const express = require('express');
const {rtcEvents} = require('../webhooks');

const webhookRoutes = express.Router();

webhookRoutes.post('/rtc/events', async (req, res) => {
  const { application_id, timestamp, type, body } = req.body;
  // console.log(`${application_id} - ${type}`);

  if(application_id !== process.env.vonageAppId) {
    res.status(403).json({status: "Invalid application id"});
    return;
  }
  if(!type) {
    res.status(404).json({status: "type not supplied"});
    return;
  }

  if(type === "conversation:created") {
    status = await rtcEvents.conversations.create(body);
  }

  res.status(200).json({status});
});

module.exports = webhookRoutes