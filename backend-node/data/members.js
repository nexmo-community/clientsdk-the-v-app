const { Pool } = require('pg');
const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});

const get = async function (client, member_id) {
  let member;
  try {
    const res = await client.query('SELECT vonage_id, conversation_id, user_id, state FROM members where vonage_id=$1', [member_id]);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return member;
}

const invited = async function (client, vonage_id, conversation_id, user_id) {
  let member = await get(vonage_id);
  if(member) {
    return member;
  }

  try {
    const res = await client.query('INSERT INTO members(vonage_id, conversation_id, user_id, state) VALUES($1, $2, $3, $4) RETURNING vonage_id, conversation_id, user_id, state', [vonage_id, conversation_id, user_id, 'INVITED']);
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

const createOrUpdate = async function (client, conversation_id, member_id, user_id, state) {
  let member = await get(client, member_id);
  if(member) {
    member = await statusUpdate(client, member_id, state);
    return member;
  }
  try {
    const res = await pool.query('INSERT INTO members(vonage_id, conversation_id, user_id, state, created_at, updated_at) VALUES($1, $2, $3, $4, NOW(), NOW()) RETURNING vonage_id, conversation_id, user_id, state', [member_id, conversation_id, user_id, state]);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
    console.log(`      | - MEMBER CREATED: ${member.vonage_id} @ ${member.state}`);
  } catch (err) {
    console.log(err);
  }
  return member;
}

const statusUpdate = async function(client, member_id, newState) {
  try {
    const res = await client.query('UPDATE members SET state=$1, updated_at=NOW() WHERE vonage_id=$2 RETURNING vonage_id, conversation_id, user_id, state', [newState, member_id]);
    if (res.rowCount === 1) {
      member = res.rows[0];
    }
    console.log(`      | - MEMBER STATUS UPDATE: ${member.vonage_id} @ ${newState}`);
  } catch (err) {
    console.log(err);
  }
  return member;
}

module.exports = {
  get,
  invited,
  createOrUpdate,
  statusUpdate
}