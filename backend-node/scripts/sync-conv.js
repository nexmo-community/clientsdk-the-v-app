console.log("Syncronising conversations...")

require('dotenv').config();
const Data = require('../data');

async function sync() {
  await Data.conversations.sync();
}

sync();