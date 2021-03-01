const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});


const Vonage = require('../vonage');
const Members = require('./members');
const Events = require('./events');

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
    const {id, type, conversation_id, to, from, body, timestamp} = vonageEvent;
    if(!id || !type || !conversation_id || !from || !body || !body.text || !timestamp) {
      return;
    }
    if(type != "text") {
      return;
    }
    let event = await Events.create(conversation_id, from, to, id, type, body.text, timestamp);
    console.dir(event);
  });
}


module.exports = {
  get,
  create,
  update,
  destroy,
  sync,
  syncMembers
}