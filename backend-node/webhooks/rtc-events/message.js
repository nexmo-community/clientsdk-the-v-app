const Data = require('../../data');

async function create(client, reqBody) {
  const { type, conversation_id, to, from, body, id, timestamp } = reqBody;
  console.log(JSON.stringify(conversation_id));
  if(!type || type != 'message' || !conversation_id || !from || !body || !id || !timestamp) {
    return 'Missing data';
  }
  const { message_type } = body;
  console.log(`MESSAGE, type: ${JSON.stringify(message_type)}`);

  let content;
  switch(message_type) {
    case "text":
      content = body.text;
      break;
    case "image":
      content = body.image.url;
    default:
      console.log(`🚨🚨🚨 UNHANDLED MESSAGE TYPE: ${message_type}`);
      console.log(req.body);
  }

  if(!content) {
    return 'Missing content';
  }

  let conversation = await Data.conversations.get(client, conversation_id);
  if(!conversation) {
    return 'Could not find the conversation';
  }

  let fromMember = await Data.members.get(client, from);
  if(to) {
    let toMember = await Data.members.get(client, to);
  }
  if(!fromMember) {
    // TODO - sync not complete
    await Data.conversations.syncMembers(client, conversation_id);
  }

  let event = await Data.events.create(client, id, `${type}.${message_type}`, conversation_id, from, to, content, timestamp);
  if(event) {
    return `Created message event: ${JSON.stringify(event)}`;
  } else {
    return 'Could not add event to the DB';
  }
}


module.exports = {
  create
}