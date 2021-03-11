console.log("Syncronising users...")

require('dotenv').config();
const DB = require('../data');

async function syncUsers() {
  console.log("sync all users into DB");
  await DB.users.sync();
}

syncUsers();