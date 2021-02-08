const Data = require('../../data');


async function create(body) {
  const { id, name, display_name, state, timestamp } = body;
  if(!id || !name || !display_name || !state || !timestamp || !timestamp.created ) {
    return 'Missing data';
  }
  const conversation = await Data.conversations.create(id, name, display_name, state, timestamp.created);
  if(conversation) {
    return `create conversation with body: ${conversation.vonage_id}`;
  } else {
    return 'Could not add conversation to the DB';
  }
}
module.exports = {
  create
}