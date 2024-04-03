import bcrypt from 'bcrypt';
import { vcr } from '@vonage/vcr-sdk';
const tableName = 'users';

const getUser = async (name) => {
    let user;

    if (process.env.STORAGE_TYPE === 'VCR') {
        user = await getUserVCR(name);
    }

    return user;
}

const getAllUsers = async () => {
    let users;

    if (process.env.STORAGE_TYPE === 'VCR') {
        users = await getAllUsersVCR();
    }

    let mappedUsers = users.map(user => ({
        id: user.id, name: user.name, display_name: user.displayName
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

const authUser = async (user, password) => {
    const isAuthed = await bcrypt.compare(password, user.password);
    if (isAuthed) {
        return { id: user.id, name: user.name, display_name: user.displayName };
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
    await state.mapSet(tableName, { [user.name]: JSON.stringify(user) } )
}

const Storage = {
    getUser,
    getAllUsers,
    storeUser,
    authUser
}

export default Storage;