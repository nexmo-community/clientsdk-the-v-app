const { Pool } = require('pg');
const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});


const conversations = require('./conversations');
const users = require('./users');


const get = async function (vonage_id) {
  let member;
  try {
    const res = await pool.query('SELECT vonage_id, conversation_id, user_id, state from members where vonage_id=$1', [vonage_id]);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return member;
}


const invited = async function (vonage_id, conversation_id, user_id) {
  let member = await get(vonage_id);
  if(member) {
    return member;
  }
  let conversation = await conversations.get(conversation_id);
  let user = await users.getByVonageId(user_id);
  if(!conversation || !user) {
    console.log(`MEMBER INVITED ERROR: 
    - conversation id: ${JSON.stringify(conversation_id)}
    - conversation: ${JSON.stringify(conversation)}
    - user id: ${JSON.stringify(user_id)}
    - user: ${JSON.stringify(user)}`);
    return member;
  }
  try {
    const res = await pool.query('INSERT INTO members(vonage_id, conversation_id, user_id, state) VALUES($1, $2, $3, $4) RETURNING vonage_id, conversation_id, user_id, state', [vonage_id, conversation_id, user_id, 'INVITED']);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
    console.log(`MEMBER INVITED:
  - id:              ${member.vonage_id}
  - user:            ${member.user_id} | ${user.name}
  - conversation_id: ${member.conversation_id} | ${conversation.name}`);
  } catch (err) {
    console.log(err);
  }
  return member;
}


const statusUpdate = async function(vonage_id, newStatus) {
  let member = await get(vonage_id);
  if(!member) {
    return member;
  }
  try {
    const res = await pool.query('UPDATE members SET state=$1 WHERE vonage_id=$2 RETURNING vonage_id, conversation_id, user_id, state', [newStatus, vonage_id]);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
    console.log(`MEMBER ${newStatus}: ${member.vonage_id}`);
  } catch (err) {
    console.log(err);
  }
  return member;
}



module.exports = {
  get,
  invited,
  statusUpdate
}
