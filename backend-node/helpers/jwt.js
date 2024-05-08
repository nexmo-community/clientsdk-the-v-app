import { tokenGenerate } from '@vonage/jwt';

const appId = process.env.VCR_API_APPLICATION_ID || process.env.appId;
const privateKey = process.env.VCR_PRIVATE_KEY || process.env.privateKey;

const aclPaths = {
  "paths": {
    "/*/rtc/**":{},
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
  return tokenGenerate(appId, privateKey, { acl: aclPaths, sub: name, user_id: vonageUserId, ttl: 3600 });
}

const JWT = {
  getAdminJWT,
  getUserJWT
}

export default JWT;