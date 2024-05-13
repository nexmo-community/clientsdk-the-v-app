import express from 'express';
import { Voice, Conversation, vcr } from '@vonage/vcr-sdk';

const webhookRoutes = express.Router();

if (process.env.STORAGE_TYPE === "VCR") {
  const voice = new Voice(vcr.getGlobalSession());
  await voice.onCall('/voice/answer');
  await voice.onCallEvent({ callback: '/voice/events'});

  const conversation = new Conversation(vcr.getGlobalSession());
  await conversation.onConversationEvent('/rtc/events');
}

webhookRoutes.post('/voice/answer', async (req, res) => {
  var ncco = [{"action": "talk", "text": "No destination user - hanging up"}];
  var username = req.body.to;
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

webhookRoutes.post('/voice/events', async (req, res) => {
  console.log(`VOICE EVENT: ${req.body}`);
  res.sendStatus(200);
});

webhookRoutes.post('/rtc/events', async (req, res) => {
  console.log(`RTC EVENT: ${req.body}`);
  res.sendStatus(200);
});

export default webhookRoutes;