const fs = require('fs');
const jwt = require('jsonwebtoken');
const uuid = require('uuid').v4;

const vonageAppId = process.env.vonageAppId;
const private_key = process.env.vonageAppPrivateKey;

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

const getUserJWT = (name, vonageId, expiration) => {
  return jwt.sign(
    {
      application_id: vonageAppId,
      iat: new Date().getTime(),
      jti: uuid(),
      sub: name,
      user_id: vonageId,
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