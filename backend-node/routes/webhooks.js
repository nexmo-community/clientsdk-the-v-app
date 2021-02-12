const express = require('express');
const {rtcEvents} = require('../webhooks');

const webhookRoutes = express.Router();

webhookRoutes.post('/rtc/events', async (req, res) => {
  const { application_id, timestamp, type, body } = req.body;
  

  if(application_id !== process.env.vonageAppId) {
    res.status(403).json({status: "Invalid application id"});
    return;
  }
  if(!type) {
    res.status(404).json({status: "type not supplied"});
    return;
  }

  let status = ""
  switch(type) {
    case  "conversation:created":
      status = await rtcEvents.conversations.create(body);
      break;
    case  "conversation:updated":
      status = await rtcEvents.conversations.update(body);
      break;
    case  "conversation:deleted":
      status = await rtcEvents.conversations.destroy(body);
      break;
    default:
      console.log(`🚨🚨🚨 UNHANDLED TYPE: ${type}`);
      console.log(req.body);
      console.log("----------------------------");
      status = `🚨🚨🚨 UNHANDLED TYPE: ${type}`;
  }

  res.status(200).json({status});
});

module.exports = webhookRoutes