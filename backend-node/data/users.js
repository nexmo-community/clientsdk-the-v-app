const crypto = require('crypto');
const { Pool } = require('pg');
const Vonage = require('../vonage');


const getAll = async function (client) {
  try {
    const res = await client.query('SELECT vonage_id, name, display_name FROM users');
    if (res.rowCount > 0 ) {
      return res.rows;
    }
  } catch (err) {
    console.log(err);
  }
  return [];
}


const getInterlocutorsFor = async function (client, user_name) {
  const users = await getAll(client);
  return users.filter(f => f.name !== user_name).map(u => { 
    return { 'id': u.vonage_id, 'name': u.name, 'display_name': u.display_name } 
  })
}


const create = async function (client, vonage_id, name, display_name, password) {
  let user;
  user = await getByName(client, name);
  if (user) {
    return user;
  }
  try {
    let passwordHash = '';
    if(password) {
      passwordHash = crypto.createHash('sha256', process.env.salt)
        .update(password)
        .digest('hex');
    }
    const res = await client.query('INSERT INTO users(vonage_id, name, display_name, password_digest, created_at, updated_at) VALUES($1, $2, $3, $4, NOW(), NOW()) RETURNING vonage_id, name, display_name', [vonage_id, name, display_name, passwordHash]);
    if (res.rowCount === 1) {
      user = res.rows[0];
    }
    console.log(`USER CREATED - ${user.vonage_id}\t${user.name} \t ${user.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return user;
}


const addPassword = async function (client, name, password) {
  try {
    let passwordHash = '';
    if(password) {
      passwordHash = crypto.createHash('sha256', process.env.salt)
        .update(password)
        .digest('hex');
    }
    const res = await client.query('UPDATE users SET password_digest=$1, updated_at=NOW() WHERE name=$2', [passwordHash, name]);
  } catch (err) {
    console.log(err);
  }
}


const authenticate = async function (client, name, password) {
  let user;
  try {
    const passwordHash = crypto.createHash('sha256', process.env.salt)
      .update(password)
      .digest('hex');
    const res = await client.query('SELECT vonage_id, name, display_name from users where name=$1::text and password_digest=$2::text', [name, passwordHash]);

    if (res.rowCount === 1) {
      user = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return user;
}


const getByName = async function (client, name) {
  let user;
  try {
    const res = await client.query('SELECT vonage_id, name, display_name, password_digest from users where name=$1', [name]);
    if (res.rowCount === 1) {
      user = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return user;
}


const getByVonageId = async function (client, vonageId) {
  let user;
  try {
    const res = await client.query('SELECT vonage_id, name, display_name, password_digest from users where vonage_id=$1', [vonageId]);
    if (res.rowCount === 1) {
      user = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return user;
}


const syncAll = async function () {
  const pool = new Pool({ connectionString: process.env.postgresDatabaseUrl });
  pool.connect(async (err, client, done) => {
    if (err) throw err
    let vonageUsers = await Vonage.users.getAll();
    console.log("retrieved " + vonageUsers.length + " vonage users");

    for (const vonageUser of vonageUsers) {
      if(!vonageUser || !vonageUser.vonage_id || !vonageUser.name || !vonageUser.display_name) {
        return;
      }
      await syncUser(client, vonageUser);
    };
    console.log("All done");
    client.release();
  });
  pool.end()
}

const syncUser = async function (client, vonageUser) {
  // console.log(vonageUser);
  // console.log(vonageUser.name);
  // find user in DB (use name as key)
  let user = await getByName(client, vonageUser.name);
  // console.log("user", user);
  if(!user) {
    // if not present (insert)
    const res = await client.query('INSERT INTO users(vonage_id, name, display_name, created_at, updated_at) VALUES($1, $2, $3, NOW(), NOW()) RETURNING vonage_id, name, display_name', [vonageUser.vonage_id, vonageUser.name, vonageUser.display_name]);
    if (res.rowCount === 1) {
      user = res.rows[0];
    }
  } else {
    // if present (update)
    const res = await client.query('UPDATE users SET vonage_id=$1, display_name=$2, updated_at=NOW() WHERE name=$3 RETURNING vonage_id, name, display_name', [vonageUser.vonage_id, vonageUser.display_name, vonageUser.name]);
    // console.log(res);
    if (res.rowCount === 1) {
      user = res.rows[0];
      console.log(`USER UPDATED - ${user.vonage_id}\t${user.name} \t ${user.display_name}`);
    }
  }
  return user
}


module.exports = {
  getAll,
  getInterlocutorsFor,
  create,
  addPassword,
  getByName,
  getByVonageId,
  authenticate,
  syncAll
}