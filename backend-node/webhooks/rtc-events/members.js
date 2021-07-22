const Data = require('../../data');

async function invited(client, reqBody) {
  const { body, conversation_id } = reqBody;
  console.log(JSON.stringify(conversation_id));
  if(!conversation_id || !body) {
    return 'Missing data';
  }
  const { user } = body;
  console.log(JSON.stringify(user));

  if(!user || !user['user_id'] || !user['member_id'] ) {
    return 'Missing data';
  }

  // already present
  let member = await Data.members.get(client, user['member_id']);
  if(member) {
    return `create member with body: ${member.vonage_id} [ALREADY EXISTS]`;
  }

  let conversation = await Data.conversations.get(client, conversation_id);
  if(!conversation) {
    return 'Could not find the conversation';
  }

  let localUser = await Data.users.getByVonageId(client, user['user_id'], true);
  if(!localUser) {
    return 'Could not find the user';
  }

  // new member
  member = await Data.members.invited(client, user['member_id'], conversation_id, user['user_id']);
  if(member) {
    return `create member with body: ${member.vonage_id}`;
  } else {
    return 'Could not add member to the DB';
  }
}

async function statusUpdate(client, newStatus, reqBody) {
  const { id, type, from, conversation_id, body, timestamp } = reqBody
  if(!id || !type || !conversation_id || !body || !timestamp) {
    return 'Missing data';
  }
  console.log(JSON.stringify(conversation_id));
  if(!conversation_id || !body) {
    return 'Missing data';
  }
  console.log(body);
  const { member_id, user } = body;
  console.log(JSON.stringify(user));

  if(!user || !user['id']) {
    return 'Missing data';
  }

  // already present
  let member = await Data.members.createOrUpdate(client, conversation_id, member_id, user['id'], newStatus);
  if(!member) {
    return `ERROR: member doesn't exist: ${from}`;
  }
  let event = await Data.events.create(client, id, type, conversation_id, from, null, null, timestamp);
  if(event) {
    console.log(`Created text event: ${JSON.stringify(event)}`);
  }

  member = await Data.members.statusUpdate(client, from, newStatus);
  if(member) {
    return `member: ${member.vonage_id} - JOINED`;
  } else {
    return 'Could not add member to the DB';
  }
}

module.exports = {
  invited,
  statusUpdate
}