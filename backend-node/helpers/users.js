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
    vonageUser = await vonage.users.createUser({ name: name, displayName: displayName });
  }
  catch (err) {
    error = err.response.data || err;
  }

  return { vonageUser, error };
}

const updateImage = async (userId, imageUrl) => {
  let vonageUser;
  let error;

  try {
    vonageUser = await vonage.users.updateUser({ id: userId, imageUrl: imageUrl });
  }
  catch (err) {
    error = err.response.data || err;
  }

  return { vonageUser, error };
}

const Users = {
  create,
  updateImage
};

export default Users;