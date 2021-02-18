const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});


const Vonage = require('../vonage');


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



const create = async (conversation_id, from_member_id, to_member_id, vonage_id, vonage_type, content, created_at) => {
  let event = await get(conversation_id, vonage_id);
  if(event) {
    return event;
  }
  try {
    const res = await pool.query('INSERT INTO events(conversation_id, from_member_id, to_member_id, vonage_id, vonage_type, content, created_at) VALUES($1, $2, $3, $4, $5, $6, $7) RETURNING conversation_id, from_member_id, to_member_id, vonage_id, vonage_type, content, created_at', [conversation_id, from_member_id, to_member_id, vonage_id, vonage_type, content, created_at]);
    if (res.rowCount === 1) {
      event = res.rows[0];
    }
    console.log(`EVENT CREATED:
  - id:           ${event.vonage_id}
  - type:         ${event.vonage_type}
  - content:      ${event.content}`);
  } catch (err) {
    console.log(err);
  }
  return event;
}


module.exports = {
  get,
  create,
}