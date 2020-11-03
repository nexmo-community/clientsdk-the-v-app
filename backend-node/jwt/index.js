const fs = require('fs');
const jwt = require('jsonwebtoken');
const uuid = require('uuid').v4;

const vonageAppId = process.env.vonageAppId;
const private_key = fs.readFileSync('./private.key', { encoding: 'utf8', flag: 'r' });

const aclPaths = {
  "paths": {
    "/*/users/**": {},
    "/*/conversations/**": {},
    "/*/sessions/**": {},
    "/*/devices/**": {},
    "/*/image/**": {},
    "/*/media/**": {},
    "/*/applications/**": {},
    "/*/push/**": {},
    "/*/knocking/**": {}
  }
};

const getAdminJWT = () => {
  return jwt.sign(
    {
      application_id: vonageAppId,
      iat: new Date().getTime(),
      jti: uuid(),
      exp: Math.round(new Date().getTime() / 1000) + 86400
    },
    private_key,
    {
      algorithm: 'RS256'
    });
}

const getUserJWT = (username, expiration) => {
  return jwt.sign(
    {
      application_id: vonageAppId,
      iat: new Date().getTime(),
      jti: uuid(),
      sub: username,
      exp: expiration | Math.round(new Date().getTime() / 1000) + 86400,
      acl: aclPaths
    },
    private_key,
    {
      algorithm: 'RS256'
    });
}

module.exports = {
  getAdminJWT,
  getUserJWT
}