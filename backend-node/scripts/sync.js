console.log("Syncronising...")

require('dotenv').config();
const Vonage = require('../vonage');
const DB = require('../data');

async function syncUsers() {
  console.log("Retrieving Vonage users...")
  let vonageUsers = await Vonage.getVonageUsers(null);
  console.log(`${vonageUsers.length} users retrieved` );
  console.log("sync all users into DB");
  await DB.users.sync(vonageUsers);
}

syncUsers();