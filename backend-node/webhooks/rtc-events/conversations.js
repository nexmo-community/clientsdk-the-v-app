const Data = require('../../data');


async function create(body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id || !name || !display_name || !state || !timestamp || !timestamp.created ) {
    return 'Missing data';
  }

  // new conversation
  conversation = await Data.conversations.create(id, name, display_name, state, timestamp.created);
  if(conversation) {
    return `create conversation with body: ${conversation.vonage_id}`;
  } else {
    return 'Could not add conversation to the DB';
  }
}


async function update(body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id || !name || !state || !timestamp || !timestamp.created ) {
    return 'Missing data';
  }

  const conversation = await Data.conversations.update(id, name, display_name, state, timestamp.created);
  return `updated conversation: ${conversation.vonage_id}`;
}

async function destroy(body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id) {
    return 'Missing data';
  }
  await Data.conversations.destroy(id);
  return `deleted conversation: ${id}`;
}



module.exports = {
  create,
  update,
  destroy
}