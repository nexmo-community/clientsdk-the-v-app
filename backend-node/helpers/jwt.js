const { tokenGenerate } = require('@vonage/jwt');

const appId = process.env.VCR_API_APPLICATION_ID || process.env.appId;
const privateKey = process.env.VCR_PRIVATE_KEY || process.env.privateKey;

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
    "/*/knocking/**": {},
    "/*/legs/**": {}
  }
};

const getAdminJWT = () => {
  return tokenGenerate(appId, privateKey);
}

const getUserJWT = (name, vonageUserId) => {
  return tokenGenerate(appId, privateKey, { acl: aclPaths, sub: name, user_id: vonageUserId });
}

module.exports = {
  getAdminJWT,
  getUserJWT
}