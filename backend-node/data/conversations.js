const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});


const Vonage = require('../vonage');
const Members = require('./members');
const Events = require('./events');
const Users = require('./users');


const getAllForUser = async function (userId) {
  try {
    const res = await pool.query('SELECT conversations.vonage_id, conversations.state, conversations.created_at FROM conversations JOIN members ON conversations.vonage_id = members.conversation_id WHERE user_id=$1', [userId]);
    if (res.rowCount > 0 ) {
      let conversations = await Promise.all(res.rows.map(async (conv) => {
        conv.id = conv.vonage_id;
        delete conv.vonage_id;

        const members = await getMembers(conv.id);
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

        let events = await getEvents(conv.id);
        // conv.events = events;

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
      }));
      return conversations;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}


const getMembers = async function (conversationId) {
  try {
    const res = await pool.query('SELECT vonage_id as member_id, conversation_id, user_id, state FROM members where conversation_id=$1', [conversationId]);
    if (res.rowCount > 0 ) {
      let members = res.rows;
      let membersWithUsers = await Promise.all(members.map(async (member) => {
        user = await Users.getByVonageId(member.user_id);
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

const getEvents = async function (conversationId) {
  try {
    const res = await pool.query('SELECT conversation_id, from_member_id, to_member_id, vonage_type, content, created_at FROM events where conversation_id=$1', [conversationId]);
    if (res.rowCount > 0 ) {
      let events = res.rows;
      return events;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}



const get = async (vonage_id, apiFallback = false) => {
  let conversation;
  try {
    const res = await pool.query('SELECT vonage_id, name, display_name, state from conversations where vonage_id=$1', [vonage_id]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  if(conversation || !apiFallback) {
    return conversation;
  }
  const { vonageConversation, error} = await Vonage.conversations.get(vonage_id);
  if(!vonageConversation) {
    return conversation;
  }
  const { id, name, display_name, state, timestamp } = vonageConversation;
  if(id && name && state && timestamp && timestamp.created ) {
    conversation = await create(id, name, display_name, state, timestamp.created);
  }
  return conversation;
}



const create = async (vonage_id, name, display_name, state, createdAt) => {
  let conversation = await get(vonage_id)
  // console.log(conversation);
  if(conversation) {
    return conversation;
  }
  try {
    const res = await pool.query('INSERT INTO conversations(vonage_id, name, display_name, state, created_at) VALUES($1, $2, $3, $4, $5) RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name || name, state, createdAt]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
    console.log(`CONVERSATION CREATED:
  - id:           ${conversation.vonage_id}
  - name:         ${conversation.name}
  - display_name: ${conversation.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return conversation;
}



const update = async (vonage_id, name, display_name, state, createdAt) => {
  let conversation = await get(vonage_id)
  // console.log(conversation);
  if(!conversation) {
    conversation = await create(vonage_id, name, display_name, state, createdAt);
    return conversation;
  }
  try {
    const res = await pool.query('UPDATE conversations SET name=$2, display_name=$3, state=$4, created_at=$5 WHERE vonage_id=$1 RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name, state, createdAt]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
    console.log(`CONVERSATION UPDATED: 
  - id:           ${conversation.vonage_id}
  - name:         ${conversation.name}
  - display_name: ${conversation.display_name}`);
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

const sync = async () => {
  console.log('Sync all conversations');
  const { vonageConversations, error} = await Vonage.conversations.getAll();
  // console.dir(conversations);
  if(!vonageConversations) {
    console.log(`NO CONVERSATIONS - ERROR:${JSON.stringify(error)}`);
    return 
  }
  vonageConversations.forEach(async (conv) => {
    if(!conv.id) { return }
    const { vonageConversation, error} = await Vonage.conversations.get(conv.id);
    // console.dir(vonageConversation);
    const { id, name, display_name, state, timestamp } = vonageConversation
    if(!id || !name || !state || !timestamp || !timestamp.created) {
      return
    }
    await update(id, name, display_name, state, timestamp.created);
    // console.dir(conversation);
    await syncMembers(id);
    await syncEvents(id);
  });
}


const syncMembers = async (conversation_id) => {
  console.log(`SYNC MEMBERS FOR: ${conversation_id}`);
  const {vonageMembers, error} = await Vonage.conversations.getMembers(conversation_id);
  if(!vonageMembers) { return; }
  console.dir(vonageMembers);
  vonageMembers.forEach(async (mem) => {
    if(!mem.id) { return; }
    const {id, state, _embedded} = mem;
    if(!id || !state || !_embedded || !_embedded.user || !_embedded.user.id) {
      return;
    }
    let member = await Members.create(id, conversation_id, _embedded.user.id, state);
    console.dir(member);
  });
}

const syncEvents = async (conversation_id) => {
  console.log(`SYNC EVENTS FOR: ${conversation_id}`);
  const {vonageEvents, error} = await Vonage.conversations.getEvents(conversation_id);
  if(!vonageEvents) { return; }
  // console.log(`vonageEvents ${JSON.stringify(vonageEvents)}`);
  vonageEvents.forEach(async (vonageEvent) => {
    const {id, type, from, body, timestamp} = vonageEvent;
    if(!id || !type || !from || !body || !timestamp) {
      return;
    }

    if(type == "text") {
      const {to} = vonageEvent;
      if(body.text) {
        let event = await Events.create(conversation_id, from, to, id, type, body.text, timestamp);
        console.dir(event);
      }
      return;
    }
    if(["member:invited", "member:joined", "member:left"].includes(type)) {
      let event = await Events.create(conversation_id, from, null, id, type, null, timestamp);
      console.dir(event);
    }

    
  });
}


module.exports = {
  getAllForUser,
  get,
  create,
  update,
  destroy,
  sync,
  syncMembers
}