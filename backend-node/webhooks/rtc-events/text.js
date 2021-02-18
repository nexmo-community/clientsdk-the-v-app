const Data = require('../../data');

async function create(reqBody) {
  const { type, conversation_id, to, from, body, id, timestamp } = reqBody;
  console.log(JSON.stringify(conversation_id));
  if(!type || type != 'text' || !conversation_id || !from || !body || !id || !timestamp) {
    return 'Missing data';
  }
  const { text } = body;
  console.log(`TEXT: ${JSON.stringify(text)}`);

  if(!text ) {
    return 'Missing data - body/text';
  }

  let conversation = await Data.conversations.get(conversation_id, true);
  if(!conversation) {
    return 'Could not find the conversation';
  }

  let fromMember = await Data.members.get(from, true);
  if(to) {
    let toMember = await Data.members.get(to, true);
  }
  if(!fromMember) {
    // TODO - sync not complete
    await Data.conversations.syncMembers(conversation_id);
  }
  // TODO - recheck the fromMember

  let event = await Data.events.create(conversation_id, from, to, id, type, text, timestamp);
  if(event) {
    return `Created text event: ${JSON.stringify(event)}`;
  } else {
    return 'Could not add event to the DB';
  }
}


module.exports = {
  create
}