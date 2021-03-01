console.log("Syncronising conversations...")

require('dotenv').config();
const DB = require('../data');

async function sync() {
  await DB.conversations.sync();
}

sync();