const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});

const get = async (conversation_id, vonage_id) => {
  let event;
  try {
    const res = await pool.query('SELECT conversation_id, from_member_id, to_member_id, vonage_id, vonage_type, content, created_at from events where conversation_id=$1 AND vonage_id=$2', [conversation_id, vonage_id]);
    if (res.rowCount === 1) {
      event = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return event;
}

const create = async (client, event_id, event_type, conversation_id, from_member_id, to_member_id, content, created_at) => {
  let event;
  try {
    const res = await client.query('INSERT INTO events(vonage_id, vonage_type, conversation_id, from_member_id, to_member_id, content, created_at) VALUES($1, $2, $3, $4, $5, $6, $7) RETURNING vonage_id, vonage_type, conversation_id, from_member_id, to_member_id, content, created_at', [event_id, event_type, conversation_id, from_member_id, to_member_id, content, created_at]);
    if (res.rowCount === 1) {
      event = res.rows[0];
    }
    console.log(`      | - EVENT CREATED: #${event.vonage_id} [${event.vonage_type}]: ${event.content}`);
  } catch (err) {
    console.log(err);
  }
  return event;
}

module.exports = {
  get,
  create,
}