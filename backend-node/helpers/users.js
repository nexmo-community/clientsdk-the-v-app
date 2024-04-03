import { Vonage } from "@vonage/server-sdk";

const appId = process.env.VCR_API_APPLICATION_ID || process.env.appId;
const privateKey = process.env.VCR_PRIVATE_KEY || process.env.privateKey;

const vonage = new Vonage(
  {
    applicationId: appId,
    privateKey: privateKey
  }
);

const create = async (name, displayName) => {
  let vonageUser;
  let error;

  try {
    vonageUser = await vonage.users.createUser({name: name, displayName: displayName});
  }
  catch (err) {
    error = err.response.data || err;
  }

  return { vonageUser, error};
}

// const addImage = async (user_id, image_url) => {}

const Users = {
  create
};

export default Users;