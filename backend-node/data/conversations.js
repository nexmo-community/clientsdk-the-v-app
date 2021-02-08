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
  console.log(conversation);
  if(conversation) {
    return conversation;
  }
  try {
    const res = await pool.query('INSERT INTO conversations(vonage_id, name, display_name, state, vonage_created_at) VALUES($1, $2, $3, $4, $5) RETURNING vonage_id, name, display_name, state', [vonage_id, name, display_name, state, createdAt]);
    if (res.rowCount === 1) {
      conversation = res.rows[0];
    }
    console.log(`CONVERSATION CREATED - ${conversation.vonage_id}\t${conversation.name} \t ${conversation.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return conversation;
}


module.exports = {
  get,
  create,
}