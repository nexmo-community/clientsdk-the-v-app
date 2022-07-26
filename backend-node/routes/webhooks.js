const express = require('express');
const { Pool } = require('pg');
const {rtcEvents} = require('../webhooks');

const webhookRoutes = express.Router();

webhookRoutes.get('/voice/answer', async (req, res) => {
  var ncco = [{"action": "talk", "text": "No destination user - hanging up"}];
  var username = req.query.to;
  if (username) {
    ncco = [
      {
        "action": "talk",
        "text": "Connecting you to " + username
      },
      {
        "action": "connect",
        "endpoint": [
          {
            "type": "app",
            "user": username
          }
        ]
      }
    ]
  }
  res.json(ncco);
});

webhookRoutes.post('/rtc/events', async (req, res) => {
  const { application_id, timestamp, type, conversation_id, body } = req.body;
  
  if(application_id !== process.env.vonageAppId) {
    res.status(403).json({status: "Invalid application id"});
    return;
  }
  if(!type) {
    res.status(404).json({status: "type not supplied"});
    return;
  }

  console.log(`🎉🎉🎉🎉 TYPE: ${type}`);
  console.log(JSON.stringify(req.body));
  console.log("----------------------------");


  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    let status = ""
    switch(type) {
      case  "conversation:created":
        status = await rtcEvents.conversations.create(client, body);
        break;
      case  "conversation:updated":
        status = await rtcEvents.conversations.update(client, body);
        break;
      case  "conversation:deleted":
        status = await rtcEvents.conversations.destroy(client, body);
        break;
      case  "member:invited":
        status = await rtcEvents.members.invited(client, req.body);
        break;
      case  "member:joined":
        status = await rtcEvents.members.statusUpdate(client, 'JOINED', req.body);
        break;
      case  "member:left":
        status = await rtcEvents.members.statusUpdate(client, 'LEFT', req.body);
        break;
      case "message":
        status = await rtcEvents.message.create(client, req.body);
        break;
      default:
        console.log(`🚨🚨🚨 UNHANDLED TYPE: ${type}`);
        console.log(req.body);
        console.log(`BODY:  ${JSON.stringify(req.body)}`);
        console.log("----------------------------");
        status = `🚨🚨🚨 UNHANDLED TYPE: ${type}`;
    }
    res.status(200).json({status});
    client.release();
  });
  pool.end();
});

module.exports = webhookRoutes