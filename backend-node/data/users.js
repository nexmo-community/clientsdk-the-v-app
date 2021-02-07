const crypto = require('crypto');
const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});
const passwordSalt = process.env.salt;

const create = async function (vonage_id, name, display_name, password) {
  let user;
  name = name.toLowerCase();
  user = await get(name);
  if (user) {
    user.status = 'existed';
    return user;
  }
  try {
    let passwordHash = '';
    if(password) {
      passwordHash = crypto.createHash('sha256', passwordSalt)
        .update(password)
        .digest('hex');
    }
    const res = await pool.query('INSERT INTO users(vonage_id, name, display_name, password_digest) VALUES($1, $2, $3, $4) RETURNING vonage_id, name, display_name', [vonage_id, name, display_name, passwordHash]);
    if (res.rowCount === 1) {
      user = res.rows[0];
      user.status = 'created';
    }
    console.log(`USER CREATED - ${user.vonage_id}\t${user.name} \t ${user.display_name}`);
  } catch (err) {
    console.log(err);
  }
  return user;
}


const addPassword = async function (name, password) {
  let user;
  name = name.toLowerCase();
  user = await get(name);
  if (user) {
    let passwordHash = '';
    if(password) {
      passwordHash = crypto.createHash('sha256', passwordSalt)
        .update(password)
        .digest('hex');
    }
    const res = await pool.query('UPDATE users SET password_digest=$1 WHERE name=$2', [passwordHash, name]);
  }
}


const authenticate = async function (name, password) {
  let user;
  try {
    name = name.toLowerCase();
    const passwordHash = crypto.createHash('sha256', passwordSalt)
      .update(password)
      .digest('hex');
    const res = await pool.query('SELECT vonage_id, name, display_name from users where name=$1::text and password_digest=$2::text', [name, passwordHash]);

    if (res.rowCount === 1) {
      user = res.rows[0];
    }

  } catch (err) {
    console.log(err);
  }

  return user;
}

const get = async function (name) {
  let user;
  try {
    name = name.toLowerCase();
    const res = await pool.query('SELECT vonage_id, name, display_name, password_digest from users where name=$1', [name]);
    if (res.rowCount === 1) {
      user = res.rows[0];
    }
  } catch (err) {
    console.log(err);
  }
  return user;
}

const sync = async function (vonageUsers) {
  // console.log(vonageUsers);
  for(let i = 0; i < vonageUsers.length; i++) {
    let vonageUser = vonageUsers[i];
    if(!vonageUser || !vonageUser.vonage_id || !vonageUser.name || !vonageUser.display_name) {
      return;
    }
    // find user in DB (use name as key)
    let user = await get(vonageUser.name)
    // if not present (insert)
    if(!user) {
      user = await create(vonageUser.vonage_id, vonageUser.name, vonageUser.display_name, null);
    } else {
      // if present (update)
      // console.log(`USER PRESENT - ${user.vonage_id}\t${user.name} \t ${user.display_name}`);
      try {
        const res = await pool.query('UPDATE users SET vonage_id=$1, display_name=$2 WHERE name=$3 RETURNING vonage_id, name, display_name', [vonageUser.vonage_id, vonageUser.display_name, vonageUser.name]);
        // console.log(res);
        if (res.rowCount === 1) {
          user = res.rows[0];
          console.log(`USER UPDATED - ${user.vonage_id}\t${user.name} \t ${user.display_name}`);
        }
      } catch (err) {
        console.log(err);
      }
    }
  };
}

module.exports = {
  create,
  addPassword,
  get,
  authenticate,
  sync
}