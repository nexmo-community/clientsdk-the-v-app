const crypto = require('crypto');
const { Pool } = require('pg');

const connectionString = process.env.postgresDatabaseUrl;
const pool = new Pool({
  connectionString
});
const passwordSalt = process.env.salt;

const createUser = async function (username, password, name) {

  let user;

  try {
    user = await findUser(username);

    if (user) {
      user.status = 'existed';
      return user;
    }

    username = username.toLowerCase();
    const passwordHash = crypto.createHash('sha256', passwordSalt)
      .update(password)
      .digest('hex');

    const res = await pool.query('INSERT INTO users(name, username, password) VALUES($1, $2, $3) RETURNING name, username', [name, username, passwordHash]);

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

    const res = await pool.query('SELECT name, username from users where username=$1::text and password=$2::text', [username, passwordHash]);

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

    const res = await pool.query('SELECT name, username from users where username=$1::text', [username]);

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