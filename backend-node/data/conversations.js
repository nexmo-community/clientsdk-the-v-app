const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});



const get = async function (vonage_id) {
  let conversation;
  try {
    const res = await pool.query('SELECT vonage_id, name, display_name, state from conversations where vonage_id=$1', [vonage_id]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return conversation;
}



const create = async function (vonage_id, name, display_name, state, createdAt) {
  let conversation = await get(vonage_id)
  // console.log(conversation);
  if(conversation) {
    return conversation;
  }
  try {
    const res = await pool.query('INSERT INTO conversations(vonage_id, name, display_name, state, created_at) VALUES($1, $2, $3, $4, $5) RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name, state, createdAt]);
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



const update = async function (vonage_id, name, display_name, state, createdAt) {
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


const destroy = async function (vonage_id) {
  let conversation = await get(vonage_id)
  // console.log(conversation);
  if(!conversation) {
    conversation = await create(vonage_id, name, display_name, state, createdAt);
    return conversation;
  }
  try {
    const res = await pool.query('UPDATE conversations SET deleted_at=NOW() WHERE vonage_id=$1', [vonage_id]);
    console.log(`CONVERSATION MARKED AS DELETED: ${vonage_id}`);
  } catch (err) {
    console.log(err);
  }
  return conversation;
}


module.exports = {
  get,
  create,
  update,
  destroy
}