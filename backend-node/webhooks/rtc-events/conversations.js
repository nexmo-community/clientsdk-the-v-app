const Data = require('../../data');

async function create(client, body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id || !name || !display_name || !state || !timestamp || !timestamp.created ) {
    return 'Missing data';
  }

  // new conversation
  conversation = await Data.conversations.create(client, id, name, display_name, state, timestamp.created);
  if(conversation) {
    return `create conversation with body: ${conversation.vonage_id}`;
  } else {
    return 'Could not add conversation to the DB';
  }
}

async function update(client, body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id || !name || !state || !timestamp || !timestamp.created ) {
    return 'Missing data';
  }

  const conversation = await Data.conversations.update(client, id, name, display_name, state, timestamp.created);

  if (conversation) {
    return `updated conversation: ${conversation.vonage_id}`;
  } else {
    return 'Conversation not found';
  }
}

async function destroy(client, body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id) {
    return 'Missing data';
  }
  await Data.conversations.destroy(client, id);
  return `deleted conversation: ${id}`;
}

module.exports = {
  create,
  update,
  destroy
}