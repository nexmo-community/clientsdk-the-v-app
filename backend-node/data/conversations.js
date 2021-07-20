const { Pool } = require('pg');
const Vonage = require('../vonage');
const Members = require('./members');
const Events = require('./events');
const Users = require('./users');


const getAllForUser = async function (client, userId) {
  try {
    const res = await client.query('SELECT conversations.vonage_id, conversations.state, conversations.created_at FROM conversations JOIN members ON conversations.vonage_id = members.conversation_id WHERE user_id=$1', [userId]);
    if (res.rowCount > 0 ) {
      let conversations = await Promise.all(res.rows.map(async (conv) => {
        return await buildConversation(client, conv, userId);
      }));
      return conversations;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}

const getConversationForUser = async function (client, conversationId, userId) {
  try {
    const res = await client.query('SELECT conversations.vonage_id, conversations.state, conversations.created_at FROM conversations JOIN members ON conversations.vonage_id = members.conversation_id WHERE conversations.vonage_id=$1 AND user_id=$2', [conversationId, userId]);
    console.log(res);
    if(res.rowCount != 1) {
      return null;
    }
    let conv = await buildConversation(client, res.rows[0], userId);
    let events = await getEvents(client, conv.id);
    console.dir(events);
    conv.events = events.filter( event => ['text','member:joined','member:left'].includes(event.vonage_type)).map( event => {
      return {
        id: event.vonage_id,
        from: event.user_id,
        type: event.vonage_type,
        content: event.content,
        timestamp: event.created_at
      }
    });
    return conv;
  } catch (err) {
    console.log(err);
  }
  return null;
}

async function buildConversation(client, conv, userId) {
  conv.id = conv.vonage_id;
  delete conv.vonage_id;

  const members = await getMembers(client, conv.id);
  const myMember = members.find(m => m.user_id == userId);
  conv.users = members.filter(m => m.user_id != userId).map(m => {
    return {
      'id': m.user_id,
      'name': m.name,
      'display_name': m.display_name,
      'state': m.state
    }
  })
  const interlocutorNames = conv.users.map(u => u.display_name);
  conv.name = interlocutorNames.join(", ");

  if(!myMember) { return; }

  let events = await getEvents(client, conv.id);

  let invitedEvent = events.find(e => e.vonage_type == 'member:invited' && e.from_member_id == myMember.member_id);
  if(invitedEvent) { 
    conv.invited_at = invitedEvent.created_at;
  }
  let joinedEvent = events.find(e => e.vonage_type == 'member:joined' && e.from_member_id == myMember.member_id);
  if(joinedEvent) { 
    conv.joined_at = joinedEvent.created_at;
  }
  let leftEvent = events.find(e => e.vonage_type == 'member:left' && e.from_member_id == myMember.member_id );
  if(leftEvent) { 
    conv.left_at = leftEvent.created_at;
  }
  return conv;
}


const getMembers = async function (client, conversationId) {
  try {
    const res = await client.query('SELECT vonage_id as member_id, conversation_id, user_id, state FROM members where conversation_id=$1', [conversationId]);
    if (res.rowCount > 0 ) {
      let members = res.rows;
      let membersWithUsers = await Promise.all(members.map(async (member) => {
        user = await Users.getByVonageId(client, member.user_id);
        member.name = user.name;
        member.display_name = user.display_name;
        return member;
      }));
      return membersWithUsers;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}

const getEvents = async function (client, conversationId) {
  try {
    const res = await client.query('SELECT events.vonage_id, events.conversation_id, events.from_member_id, events.to_member_id, events.vonage_type, events.content, events.created_at, members.user_id FROM events JOIN members ON events.from_member_id = members.vonage_id WHERE events.conversation_id=$1', [conversationId]);
    if (res.rowCount > 0 ) {
      let events = res.rows;
      return events;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}



const get = async (client, vonage_id) => {
  let conversation;
  try {
    const res = await client.query('SELECT vonage_id, name, display_name, state from conversations where vonage_id=$1', [vonage_id]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return conversation;
}



const create = async (client, vonage_id, name, display_name, state, createdAt) => {
  let conversation;
  try {
    const res = await client.query('INSERT INTO conversations(vonage_id, name, display_name, state, created_at, updated_at) VALUES($1, $2, $3, $4, $5, NOW()) RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name || name, state, createdAt]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
    console.log('  | - created');
  //   console.log(`CONVERSATION CREATED:
  // - id:           ${conversation.vonage_id}
  // - name:         ${conversation.name}
  // - display_name: ${conversation.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return conversation;
}


const createConversationForUserWithInterlocutors  = async (client, userId, users) => {
  const newConversation = await Vonage.conversations.create(userId, users);
  console.dir(newConversation);
  if(!newConversation) { return }
  await create(client, newConversation.id, newConversation.name, newConversation.display_name, newConversation.state, newConversation.timestamp.created);

  // add the members
  users.push(userId);
  for(let i = 0; i < users.length; i++) {
    let user = users[i];
    const member = await Vonage.conversations.createMember(newConversation.id, user);
    // console.dir(member);
    if(member) {
      await Members.createOrUpdate(client, newConversation.id, member.id, user, member.state);
    }
  };

  const conv = await getConversationForUser(client, newConversation.id, userId);
  return conv;
}


const update = async (client, vonage_id, name, display_name, state, createdAt) => {
  let conversation;
  try {
    const res = await client.query('UPDATE conversations SET name=$2, display_name=$3, state=$4, created_at=$5, updated_at=NOW() WHERE vonage_id=$1 RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name, state, createdAt]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
    console.log('  | - updated');
  //   console.log(`CONVERSATION UPDATED: 
  // - id:           ${conversation.vonage_id}
  // - name:         ${conversation.name}
  // - display_name: ${conversation.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return conversation;
}


const destroy = async (vonage_id) => {
  let conversation = await get(vonage_id);
  // console.log(conversation);
  if(!conversation) {
    return;
  }
  try {
    const res = await pool.query('UPDATE conversations SET deleted_at=NOW() WHERE vonage_id=$1', [vonage_id]);
    console.log(`CONVERSATION MARKED AS DELETED: ${vonage_id}`);
  } catch (err) {
    console.log(err);
  }
  return;
}

const syncAll = async () => {
  console.log('Sync all conversations');
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    const { vonageConversations, error} = await Vonage.conversations.getAll();
    console.log("retrieved " + vonageConversations.length + " conversations");
    if(!vonageConversations) {
      console.log(`NO CONVERSATIONS - ERROR:${JSON.stringify(error)}`);
      return 
    }
    for (const vonageConversationLight of vonageConversations) {
     await syncConversation(client, vonageConversationLight);
    };
    console.log("All done");
    client.release();
  });
  pool.end()
}

const syncConversation = async (client, vonageConversationLight) => {
  if(!vonageConversationLight.id) { return }
  const { vonageConversation, error} = await Vonage.conversations.get(vonageConversationLight.id);
  // console.dir(vonageConversation);
  if(error) {
    console.log(`ERROR: ${JSON.stringify(error)}`);
    console.log(vonageConversationLight);
    return;
  }
  try {
    const { id, name, display_name, state, timestamp } = vonageConversation
    if(!id || !name || !state || !timestamp || !timestamp.created) {
      return
    }
    let conversation = await get(client, id);
    if(!conversation) {
      conversation = await create(client, id, name, display_name, state, timestamp.created);
    } else {
      conversation = await update(client, id, name, display_name, state, timestamp.created);
    }
    await syncMembers(client, id);
    await syncEvents(client, id);
  } catch (err) {
    console.log(err, vonageConversationLight), vonageConversation;
  }
}

const syncMembers = async (client, conversation_id) => {
  console.log(`  | - SYNC MEMBERS FOR: ${conversation_id}`);
  const {vonageMembers, error} = await Vonage.conversations.getMembers(conversation_id);
  console.log("      | - retrieved " + vonageMembers.length + " members");
  for (const vonageMember of vonageMembers) {
    if(!vonageMember.id) { return; }
    const {id, state, _embedded} = vonageMember;
    if(!id || !state || !_embedded || !_embedded.user || !_embedded.user.id) {
      return;
    }
    let member = await Members.createOrUpdate(client, conversation_id, id, _embedded.user.id, state);
    // console.dir(member);
  };
}

const syncEvents = async (client, conversation_id) => {
  console.log(`  | - SYNC EVENTS FOR: ${conversation_id}`);
  const {vonageEvents, error} = await Vonage.conversations.getEvents(conversation_id);
  console.log("      | - retrieved " + vonageEvents.length + " events");
  
  for (const vonageEvent of vonageEvents) {
    if(!vonageEvent.id) { return; }
    const {id, type, from, body, timestamp} = vonageEvent;
    if(!id || !type || !from || !body || !timestamp) {
      return;
    }
    if(["member:invited", "member:joined", "member:left"].includes(type)) {
      let event = await Events.create(client, id, type, conversation_id, from, null, null, timestamp);
      // console.dir(event);
    }
    if(type == "text") {
      const {to} = vonageEvent;
      if(body.text) {
        let event = await Events.create(client, id, type, conversation_id, from, to, body.text, timestamp);
        // console.dir(event);
      }
      return;
    }
  }
}


module.exports = {
  getAllForUser,
  getConversationForUser,
  get,
  create,
  createConversationForUserWithInterlocutors,
  update,
  destroy,
  syncAll,
  syncMembers
}