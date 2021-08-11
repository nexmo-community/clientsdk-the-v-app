const Data = require('../../data');

async function create(client, reqBody) {
  const { type, conversation_id, to, from, body, id, timestamp } = reqBody;
  console.log(JSON.stringify(conversation_id));
  if(!type || type != 'image' || !conversation_id || !from || !body || !id || !timestamp) {
    return 'Missing data';
  }
  const { url } = body.representations.original;
  console.log(`URL: ${JSON.stringify(url)}`);

  if(!url ) {
    return 'Missing data - body/representations/original/url';
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
  // TODO - recheck the fromMember

  let event = await Data.events.create(client, id, type, conversation_id, from, to, url, timestamp);
  if(event) {
    return `Created image event: ${JSON.stringify(event)}`;
  } else {
    return 'Could not add event to the DB';
  }
}


module.exports = {
  create
}
