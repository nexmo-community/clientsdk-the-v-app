import { Assets, vcr } from '@vonage/vcr-sdk';
import bcrypt from 'bcrypt';
import crypto from 'crypto';
import path from 'path';
import fs from 'fs';
import os from 'os';

const tableName = 'users';

/*
If you are not using VCR for storage here are the objects and their fields

User:

{ id: "", name: "", display_name: "", image_url: "", password: "" }

Users:

[{ id: "", name: "", display_name: "", image_url: "", password: "" }]
*/

const getUser = async (name) => {
    let user;

    if (process.env.STORAGE_TYPE === 'VCR') {
        user = await getUserVCR(name);
    }

    return user;
}

const updateUser = async (name, imageUrl) => {
    let user;

    if (process.env.STORAGE_TYPE === 'VCR') {
        user = await getUserVCR(name);
        user.imageUrl = imageUrl;
        await storeUserVCR(user);
    }

    return user;
}

const getAllUsers = async () => {
    let users;

    if (process.env.STORAGE_TYPE === 'VCR') {
        users = await getAllUsersVCR();
    }

    let mappedUsers = users.map(user => ({
        id: user.id, name: user.name, display_name: user.displayName, image_url: user.imageUrl
    }));

    return mappedUsers
}

const storeUser = async (id, name, displayName, password) => {
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = {
        id: id,
        name: name,
        displayName: displayName,
        password: hashedPassword
    };

    if (process.env.STORAGE_TYPE === 'VCR') {
        await storeUserVCR(user);
    }

    return { id: id, name: name, display_name: displayName };
}

const storeUserImage = async (userId, imageBuffer) => {
    if (process.env.STORAGE_TYPE === 'VCR') {
        const imageUrl = await storeImageVCR(`vapp/profiles/${userId}`, imageBuffer);
        return imageUrl;
    }
}

const storeImage = async (imageBuffer) => {
    if (process.env.STORAGE_TYPE === 'VCR') {
        const imageUrl = await storeImageVCR('vapp/chat/images', imageBuffer);
        return imageUrl;
    }
}

const authUser = async (user, password) => {
    const isAuthed = await bcrypt.compare(password, user.password);
    if (isAuthed) {
        return { id: user.id, name: user.name, display_name: user.displayName, image_url: user.imageUrl };
    } else {
        return null;
    }
}

async function getUserVCR(name) {
    const state = vcr.getInstanceState();
    let user = await state.mapGetValue(tableName, name);
    user = JSON.parse(user);

    return user
}

async function getAllUsersVCR() {
    const state = vcr.getInstanceState();
    let users = await state.mapGetValues(tableName);
    users = users.map(user => JSON.parse(user));

    return users;
}

async function storeUserVCR(user) {
    const state = vcr.getInstanceState();
    await state.mapSet(tableName, { [user.name]: JSON.stringify(user) })
}

async function storeImageVCR(basePath, imageFile) {
    const assets = new Assets(vcr.getGlobalSession());

    const fileExtension = mimeTypeToExtension(imageFile.mimetype);
    const filename = `${generateRandomString(10)}.${fileExtension}`;
    const filePath = path.join(os.tmpdir(), filename);

    await fs.writeFileSync(filePath, imageFile.buffer);
    await assets.uploadFiles([filePath], basePath);

    let link = await assets.generateLink(`${basePath}/${filename}`, '999d');
    return link.downloadUrl;
}

function mimeTypeToExtension(mimeType) {
    const parts = mimeType.split('/');
    if (parts.length === 2) {
        return parts[1];
    } else {
        return null;
    }
}

function generateRandomString(length) {
    return crypto.randomBytes(Math.ceil(length / 2))
        .toString('hex')
        .slice(0, length);
}


const Storage = {
    getUser,
    updateUser,
    getAllUsers,
    storeUser,
    storeUserImage,
    storeImage,
    authUser
}

export default Storage;