const Data = require('../../data');

async function invited(reqBody) {
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
  let member = await Data.members.get(user['member_id']);
  if(member) {
    return `create member with body: ${member.vonage_id} [ALREADY EXISTS]`;
  }

  let conversation = await Data.conversations.get(conversation_id, true);
  if(!conversation) {
    return 'Could not find the conversation';
  }

  let localUser = await Data.users.getByVonageId(user['user_id'], true);
  if(!localUser) {
    return 'Could not find the user';
  }

  // new member
  member = await Data.members.invited(user['member_id'], conversation_id, user['user_id']);
  if(member) {
    return `create member with body: ${member.vonage_id}`;
  } else {
    return 'Could not add member to the DB';
  }
}

async function statusUpdate(newStatus, reqBody) {
  const { from, conversation_id, body } = reqBody;
  console.log(JSON.stringify(conversation_id));
  if(!conversation_id || !body) {
    return 'Missing data';
  }
  const { user } = body;
  console.log(JSON.stringify(user));

  if(!user || !user['id']) {
    return 'Missing data';
  }

  // already present
  let member = await Data.members.get(from);
  if(!member) {
    return `ERROR: member doesn't exist: ${from}`;
  }
  member = await Data.members.statusUpdate(from, newStatus);
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