const crypto = require('crypto');

const { Client } = require('pg');
const connectionString = process.env.postgresDatabaseUrl;
const client = new Client({
  connectionString
});

const passwordSalt = process.env.salt;

const createUser = async function (username, password, name) {

  let user;

  try {

    await client.connect();

    user = await findUser(username);

    if (user) {
      await client.end();
      user.status = 'existed';
      return user;
    }

    username = username.toLowerCase();
    const passwordHash = crypto.createHash('sha256', passwordSalt)
      .update(password)
      .digest('hex');

    const res = await client.query('INSERT INTO users(name, username, password) VALUES($1, $2, $3) RETURNING name, username', [name, username, passwordHash]);
    await client.end();

    if (res.rowCount === 1) {
      user = res.rows[0];
      user.status = 'created';
    }

  } catch (err) {
    console.log(err);
  }

  return user;
}

const identifyUser = async function (username, password) {

  let user;

  try {

    username = username.toLowerCase();
    const passwordHash = crypto.createHash('sha256', passwordSalt)
      .update(password)
      .digest('hex');

    await client.connect();
    const res = await client.query('SELECT name, username from users where username=$1::text and password=$2::text', [username, passwordHash]);
    await client.end();

    if (res.rowCount === 1) {
      user = res.rows[0];
    }

  } catch (err) {
    console.log(err);
  }

  return user;
}

const findUser = async function (username) {

  let user;

  try {

    username = username.toLowerCase();

    const res = await client.query('SELECT name, username from users where username=$1::text', [username]);

    if (res.rowCount === 1) {
      user = res.rows[0];
    }

  } catch (err) {
    console.log(err);
  }

  return user;
}

module.exports = {
  createUser,
  identifyUser
}