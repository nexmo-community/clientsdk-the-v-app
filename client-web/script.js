const NexmoClient = window.NexmoClient;

console.log('window NexmoClient: ', NexmoClient);

const BASE_URL = "https://v-app-companion.herokuapp.com";
// const BASE_URL = "https://abdulajet.ngrok.io"

// Get reference to elements
const messageTextarea = document.querySelector("#messageTextarea");
const messageFeed = document.querySelector("#messageFeed");
const sendButton = document.querySelector("#send");
const status = document.querySelector("#status");
const messages = document.querySelector("#messages");
const sessionName = document.querySelector("#sessionName");
const loadMessagesButton = document.querySelector("#loadMessages");
const messagesCountSpan = document.querySelector("#messagesCount");
const messageDateSpan = document.querySelector("#messageDate");

const loginSignUpSection = document.querySelector("#login-signup");

const loginForm = document.querySelector("#login");
const usernameLogin = document.querySelector("#username-login");
const passwordLogin = document.querySelector("#password-login");

const signupForm = document.querySelector("#signup");
const usernameSignup = document.querySelector("#username-signup");
const displayNameSignup = document.querySelector("#display-name-signup");
const passwordSignup = document.querySelector("#password-signup");

const loginSignupStatus = document.querySelector("#login-signup-status");

const dashboardSection = document.querySelector("#dashboard");
const contentDiv = document.querySelector("#content");

const usersList = document.querySelector("#users-list");
const usersListItemTemplate = document.querySelector("#users-list-item-template");

const textChatList = document.querySelector("#text-chat-list");
const textChatListItemTemplate = document.querySelector("#text-chat-list-item-template");

const selectedUserProfileTemplate = document.querySelector("#selected-user-profile-template");

const settingsDiv = document.querySelector("#settings");
const settingsTemplate = document.querySelector("#settings-template");

const textChatTemplate = document.querySelector("#text-chat-template");

const chatContainer = document.querySelector("#chat-container");
const vonageInput = document.querySelector("vc-text-input");
const vonageTypingIndicator = document.querySelector("vc-typing-indicator");
const vonageMembers = document.querySelector("vc-members");
const vonageMessagesFeed = document.querySelector("vc-messages");

const groupChatCreateTemplate = document.querySelector("#group-chat-create-template");
const createGroupChatButton = document.querySelector("#create-group-chat");

const foundPreviousChatsTemplate = document.querySelector("#found-previous-chats-template");

const tab3 = document.querySelector("#tab-3");
const tab4 = document.querySelector("#tab-4");
const tab5 = document.querySelector("#tab-5");

// Global variables
let client;
let app;
let conversation;
let listedEvents;
let messagesCount = 0;
let messageDate;
let call;

let myUser = {};
let conversations = [];
let jwt;
let users = [];

let selectedConversation = {};
let selectedUser = {};

let currentCall;


function iconOrTextTab() {
    console.log("window.innerWidth: ", window.innerWidth);
    if (window.innerWidth > 950) {
        tab3.innerText = "Chats";
        tab4.innerText = "Contacts";
        tab5.innerText = "Settings";
    } else {
        tab3.innerText = "💬";
        tab4.innerText = "👥";
        tab5.innerText = "⚙️";
    }
}
iconOrTextTab();
window.onresize = iconOrTextTab;

// Set up tabs. Code based on: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/Tab_Role
const tabs = document.querySelectorAll('[role="tab"]');
const tabLists = document.querySelectorAll('[role="tablist"]');

function changeTabs(e) {
    const target = e.target;
    const parent = target.parentNode;
    const grandparent = parent.parentNode;

    // Remove all current selected tabs
    parent
        .querySelectorAll('[aria-selected="true"]')
        .forEach(t => t.setAttribute("aria-selected", false));

    // Set this tab as selected
    target.setAttribute("aria-selected", true);

    // Hide all tab panels
    grandparent
        .querySelectorAll('[role="tabpanel"]')
        .forEach(p => p.setAttribute("hidden", true));

    // Show the selected panel
    grandparent.parentNode
        .querySelector(`#${target.getAttribute("aria-controls")}`)
        .removeAttribute("hidden");
}

// Add a click event handler to each tab
tabs.forEach(tab => {
    tab.addEventListener("click", changeTabs);
});

// Enable arrow navigation between tabs in the tab list
let tabFocus = 0;

tabLists.forEach(tabList => {
    tabList.addEventListener("keydown", e => {
        // Move right
        if (e.keyCode === 39 || e.keyCode === 37) {
            tabs[tabFocus].setAttribute("tabindex", -1);
            if (e.keyCode === 39) {
                tabFocus++;
                // If we're at the end, go to the start
                if (tabFocus >= tabs.length) {
                    tabFocus = 0;
                }
                // Move left
            } else if (e.keyCode === 37) {
                tabFocus--;
                // If we're at the start, move to the end
                if (tabFocus < 0) {
                    tabFocus = tabs.length - 1;
                }
            }

            tabs[tabFocus].setAttribute("tabindex", 0);
            tabs[tabFocus].focus();
        }
    });

});

async function postRequest(endpoint = "", data = {}) {
    try {
        const response = await fetch(BASE_URL + endpoint, {
            method: 'POST', // *GET, POST, PUT, DELETE, etc.
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${jwt}`
            },
            body: JSON.stringify(data) // body data type must match "Content-Type" header
        });
        if (!response.ok) {
            throw await response.json();
        }
        return response.json();

    } catch (error) {
        console.error("postRequest error: ", error);
        throw error;
    }
}


async function getRequest(endpoint = "") {
    try {
        const response = await fetch(BASE_URL + endpoint, {
            method: 'GET', // *GET, POST, PUT, DELETE, etc.
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${jwt}`
            }
        });
        if (!response.ok) {
            throw await response.json();
        }
        return response.json();

    } catch (error) {
        console.error("postRequest error: ", error);
        throw error;
    }
}



function displayError(element, error) {
    let errorText = "Error: ";
    if (error.type === "data:validation") {
        errorText += "<ul>"
        for (let i = 0; i < error.invalid_parameters.length; i++) {
            errorText += `<li>${error.invalid_parameters[i].name} ${error.invalid_parameters[i].reason} </li>`;
        }
        errorText += "</ul>"
    } else {
        errorText += error.detail;
    }
    element.innerHTML = errorText;
}

function callButtonClickHandler(e) {
    console.log("callButtonClickHandler: ", e.target.dataset.username);
    app.callServer(e.target.dataset.username, "app").then((nxmCall) => {
        console.log('Calling user(s)...', nxmCall);
        currentCall = nxmCall;
    }).catch((error) => {
        console.error(error);
    });
}

function hangupButtonClickHandler() {
    currentCall.hangUp({ reason_code: '404', reason_text: 'User hung up' }).then((event) => {
        console.log('hang up event', event);
    }).catch((error) => {
        console.error(error);
    });
}

function showSelectedUser(user, answeringCall = false) {
    console.log("user: ", user);
    console.log("answeringCall: ", answeringCall);
    const username = answeringCall ? user.name : user.target.dataset.username;
    let profileImage = answeringCall ? user.image_url : user.target.dataset.userProfileImage;
    const displayName = answeringCall ? user.display_name : user.target.innerText;
    const userId = answeringCall ? user.id : user.target.dataset.userId;

    console.log("username: ", username);
    console.log("profileImage: ", profileImage);
    console.log("displayName: ", displayName);
    console.log("userId: ", userId);

    if (profileImage === null || profileImage === "null") {
        profileImage = `https://robohash.org/${username}`;
    }
    console.log("profileImage new: ", profileImage);

    contentDiv.innerHTML = "";
    //See if there's already a text chat
    const previousChats = conversations.filter((conversation) => conversation.users.some((user) => user.id === userId));
    console.log("previousChats: ", previousChats);
    // separate group chats from 1 to 1 chat
    const groupChats = previousChats.filter((conversation) => conversation.users.length > 1);
    console.log("groupChats: ", groupChats);
    const oneToOneChat = previousChats.filter((conversation) => conversation.users.length === 1);
    console.log("one to one chat: ", oneToOneChat);

    const selectedUserProfileClone = selectedUserProfileTemplate.content.cloneNode(true);
    const img = selectedUserProfileClone.querySelector("img");
    const name = selectedUserProfileClone.querySelector("#display-name");
    const messageButton = selectedUserProfileClone.querySelector("#message-user");
    const groupChatsContainer = selectedUserProfileClone.querySelector("#group-chats-container");
    const groupChatsList = selectedUserProfileClone.querySelector("#group-chats");
    if (groupChats.length > 0) {
        // list the group chats and add to ul
        groupChats.forEach(textChat => {
            const textChatListItemClone = textChatListItemTemplate.content.cloneNode(true);
            const li = textChatListItemClone.querySelector("li");
            li.textContent = textChat.name;
            li.dataset.id = textChat.id;
            li.addEventListener("click", () => displayTextChat(textChat.id));
            groupChatsContainer.appendChild(textChatListItemClone);
        });
    } else {
        // set the group chats container to display none;
        groupChatsContainer.style.display = "none";
    }

    messageButton.dataset.convId = oneToOneChat.length > 0 ? oneToOneChat[0].id : "";

    messageButton.dataset.username = username;
    messageButton.dataset.userId = userId;
    messageButton.innerText = previousChats.length > 0 ? "Open Chat" : "Create Chat";
    messageButton.addEventListener("click", textChatClickHandler);
    const callButton = selectedUserProfileClone.querySelector("#call-user");
    callButton.dataset.username = username;
    const hangupButton = selectedUserProfileClone.querySelector("#hangup-user");
    if (answeringCall) {
        callButton.style.display = "none";
    } else {
        hangupButton.style.display = "none";
    }
    // img.src = profileImage === "null" ? `https://robohash.org/${username}` : profileImage;
    img.src = profileImage;
    name.innerText = displayName;
    callButton.addEventListener("click", callButtonClickHandler);
    hangupButton.addEventListener("click", hangupButtonClickHandler);
    contentDiv.appendChild(selectedUserProfileClone);

}


function logoutClickHandler(e) {
    console.log("logout!");
    client.logout().then((response) => {
        console.log("logout response: ", response);
        settingsDiv.innerHTML = "";
        contentDiv.innerHTML = "<div class='center'><img class='vonage-spin' src='https://cdn.glitch.global/41750a77-8d9a-4701-96f4-80f4ffcb5e31/vonage-spin.gif?v=1646775708339'></div>";
        dashboardSection.style.display = "none";
        loginSignUpSection.style.display = "flex";

    }).catch((error) => {
        console.log("logout error: ", error);
    });

}


// Set up Vonage Application
async function setupApplication() {
    try {
        client = new NexmoClient({ debug: false });
        app = await client.login(jwt);
        console.log('app: ', app);

        app.on("call:status:changed", (nxmCall) => {
            console.log('call:status:changed nxmCall: ', nxmCall);
            const callButton = document.querySelector("#call-user");
            const hangupButton = document.querySelector("#hangup-user");
            const callStatus = document.querySelector("#call-status");
            if (callStatus) {
                callStatus.innerText = nxmCall.status
            }
            console.log("callButton: ", callButton);
            console.log("hangupButton: ", hangupButton);
            // call = nxmCall;
            if (callButton || hangupButton) {
                if (nxmCall.status === nxmCall.CALL_STATUS.RINGING) {
                    console.log('the call is ringing');
                    callButton.disabled = true;
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.ANSWERED) {
                    console.log('the call has been answered');
                    callButton.disabled = false;
                    callButton.style.display = "none";
                    hangupButton.style.display = "block";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.STARTED) {
                    console.log('the call has started');
                    callButton.disabled = false;
                    callButton.style.display = "none";
                    hangupButton.style.display = "block";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.COMPLETED) {
                    console.log('the call has completed');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.BUSY) {
                    console.log('the call is busy');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.FAILED) {
                    console.log('the call has failed');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.TIMEOUT) {
                    console.log('the call has timed out');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.UNANSWERED) {
                    console.log('the call has timed out');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

                if (nxmCall.status === nxmCall.CALL_STATUS.REJECTED) {
                    console.log('the call was rejected');
                    callButton.disabled = false;
                    callButton.style.display = "block";
                    hangupButton.style.display = "none";
                }

            }
        });

        app.on("member:call", (member, nxmCall) => {
            console.log("typeof: ", typeof nxmCall)
            console.log("member:call member: ", member);
            console.log("member:call NXMCall answer: ", nxmCall);
            currentCall = nxmCall;
            //Get other member of conversation
            let otherMember;
            for (let [key, value] of nxmCall.conversation.members) {
                if (key !== member.id) {
                    console.log('other member: ', value);
                    otherMember = value;
                }
            }

            if (member.state === "INVITED") {
                // Need this for inAppCall & callSever doesn't send member.invited_by
                if (!member.initiator.invited.isSystem) {
                    if (window.confirm(`Accept invite from ${member.invited_by}?`)) {
                        nxmCall.answer();
                    } else {
                        nxmCall.reject({ reason_code: '403', reason_text: 'User turned down request' }).then(() => {
                            console.log('Call rejected.');
                        }).catch((error) => {
                            console.error(error);
                        });
                    }

                } else {
                    console.log("myUser: ", myUser);
                    console.log("users: ", users);
                    const otherUser = users.find(user => otherMember.user.id === user.id);
                    if (window.confirm(`Join audio call with ${otherMember.display_name}?`)) {
                        showSelectedUser(otherUser, true);
                        nxmCall.answer();

                    } else {
                        nxmCall.reject({ reason_code: '403', reason_text: 'User turned down request' }).then(() => {
                            console.log('Call rejected.');
                        }).catch((error) => {
                            console.error(error);
                        });
                    }

                }

            }


        });

        app.on("member:invited", (member, event) => {
            console.log("member:invited member: ", member);
            console.log("member:invited event: ", event);
        });

        app.on("member:joined", async (member, event) => {
            console.log("member:joined member: ", member);
            console.log("member:joined event: ", event);
            console.log("member.conversation.callbacks['member:media']: ", member.conversation.callbacks['member:media']);
            // check to see if it is an audio call
            console.log("event.body.channel.legs: ", event.body.channel.legs.length)
            if (!member.conversation.callbacks['member:media']) {
                // make a call to get the name of the text chat
                const textChat = await getRequest(`/conversations/${event.cid}`);
                console.log("textChat: ", textChat);
                conversations.push(textChat);
                console.log("conversations: ", conversations);
                const textChatListItemClone = textChatListItemTemplate.content.cloneNode(true);
                const li = textChatListItemClone.querySelector("li");
                li.textContent = textChat.name;
                li.dataset.id = textChat.id;
                li.addEventListener("click", () => displayTextChat(textChat.id));
                textChatList.appendChild(textChatListItemClone);
            }

        });



        return;
    }
    catch (error) {
        console.error('error in setup: ', error);
        return;
    }

}

async function displayTextChat(selectedConversationId) {
    console.log("displatyTextChat selectedConversationId: ", selectedConversationId);

    contentDiv.innerHTML = "";
    const textChatClone = textChatTemplate.content.cloneNode(true);
    const vonageInput = textChatClone.querySelector("vc-text-input");
    const vonageTypingIndicator = textChatClone.querySelector("vc-typing-indicator");
    const vonageMembers = textChatClone.querySelector("vc-members");
    const vonageMessagesFeed = textChatClone.querySelector("vc-messages");


    contentDiv.appendChild(textChatClone);

    const selectedConversation = await getRequest(`/conversations/${selectedConversationId}`);

    console.log('selected conversation: ', selectedConversation);
    const conversationObj = await app.getConversation(selectedConversation.id);
    console.log("conversationObj: ", conversationObj);


    let convMembers = [];
    const params = {
        order: "desc",
        page_size: 100
    }
    await conversationObj.getMembers(params).then((members_page) => {
        console.log("members_page: ", members_page);
        members_page.items.forEach(member => {
            console.log("member: ", member)
            convMembers.push(member);
        })
    }).catch((error) => {
        console.error("error getting the members ", error);
    });
    let myMember = convMembers.filter((member) => myUser.id === member.user.id);
    console.log("myMember: ", myMember);
    const previousMessages = selectedConversation.events.reduce((previousValue, currentValue) => {
        if (!previousValue.some((previous) => previous.id === currentValue.id)) {
            if (currentValue.type === "text") {
                previousValue.push(currentValue);
            }
        }
        return previousValue
    }, [{ id: "", type: "" }]);
    const messages = previousMessages.filter(message => message.id !== "").sort(function (a, b) {
        return a.id - b.id;
    });;
    console.log("messages: ", messages);

    // format messages
    console.log("convMembers: ", convMembers);
    const formattedMessages = messages.map((message) => {
        const matchingMember = convMembers.filter((member) => message.from === member.user.id);
        console.log("matchingMember: ", matchingMember);
        return {
            message: {
                body: { text: message.content },
                from: matchingMember[0].id
            },
            sender: {
                displayName: matchingMember[0].display_name
            }
        }
    });
    console.log("formattedMessages: ", formattedMessages);

    vonageMembers.members = [];
    vonageInput.conversation = conversationObj;
    vonageTypingIndicator.conversation = conversationObj;
    vonageMembers.conversation = conversationObj;
    vonageMessagesFeed.conversation = conversationObj;
    vonageMessagesFeed.myId = myMember[0].id
    vonageMessagesFeed.messages = formattedMessages;


}

async function textChatClickHandler(e) {
    console.log("textChatClickHandler: ", e.target.dataset.convId);
    console.log("myUserL: ", myUser);
    const messageUser = document.querySelector("#message-user");
    const callStatus = document.querySelector("#call-status");
    selectedConversation = "";
    callStatus.innerText = "";
    if (e.target.dataset.convId) {
        callStatus.innerText = "Loading Chat...";
        try {
            messageUser.disabled = true;
            displayTextChat(e.target.dataset.convId);
        } catch (e) {
            console.log("got an error: ", e);
            messageUser.disabled = false;
            callStatus.innerText = e;
        }
    } else {
        console.log("need to create a conversation w/ ", e.target.dataset.username, e.target.dataset.userId);
        callStatus.innerText = "Creating Chat...";
        try {
            messageUser.disabled = true;

            const bodyData = {
                users: [e.target.dataset.userId]
            }
            selectedConversation = await postRequest("/conversations", bodyData)
            console.log('selected conversation: ', selectedConversation.events);
            displayTextChat(selectedConversation.id);

        } catch (e) {
            console.log("got an error: ", e);
            messageUser.disabled = false;
            callStatus.innerText = e;
        }

    }
}


async function showDashboard(data) {
    console.log("showDashboard: ", data);
    tabFocus = 2;

    loginSignUpSection.style.display = "none";
    myUser = data.user;
    conversations = data.conversations;
    console.log('conversations: ', conversations);
    jwt = data.token;
    await setupApplication();
    users = data.users.sort(function (a, b) {
        var nameA = a.display_name.toUpperCase(); // ignore upper and lowercase
        var nameB = b.display_name.toUpperCase(); // ignore upper and lowercase
        if (nameA < nameB) {
            return -1;
        }
        if (nameA > nameB) {
            return 1;
        }
        // names must be equal
        return 0;
    });

    users.forEach(user => {
        const userClone = usersListItemTemplate.content.cloneNode(true);
        const button = userClone.querySelector("button");
        button.textContent = user.display_name;
        button.dataset.userId = user.id;
        button.dataset.username = user.name;
        button.dataset.userProfileImage = user.image_url;
        button.addEventListener("click", showSelectedUser);
        usersList.appendChild(userClone);
    });


    // get text chat conversations and list
    const textChats = await getRequest("/conversations");
    console.log('textChats: ', textChats);
    textChats.forEach(textChat => {
        const textChatListItemClone = textChatListItemTemplate.content.cloneNode(true);
        const li = textChatListItemClone.querySelector("li");
        li.textContent = textChat.name;
        li.dataset.id = textChat.id;
        li.addEventListener("click", () => displayTextChat(textChat.id));
        textChatList.appendChild(textChatListItemClone);
    });

    // Set up Settings tab
    const settingsClone = settingsTemplate.content.cloneNode(true);
    const settingsImg = settingsClone.querySelector("img");
    const settingsDisplayName = settingsClone.querySelector("#user-display-name");
    const settingLogoutButton = settingsClone.querySelector("#logout");

    settingsImg.src = myUser.image_url === null ? `https://robohash.org/${myUser.name}` : myUser.image_url;
    settingsDisplayName.innerText = myUser.display_name;
    settingLogoutButton.addEventListener("click", logoutClickHandler);

    settingsDiv.appendChild(settingsClone);



    dashboardSection.style.display = "flex";


}

async function createGroupHandler(e) {
    console.log("createGroupHandler: ", e);
    e.preventDefault();
    const createGroupChatButton = document.querySelector('#group-chat-create-button');
    const status = document.querySelector('#group-chat-status');
    status.innerText = "";
    const checkedUsersNL = document.querySelectorAll('input[name="user"]:checked');
    const checkedUsers = Array.from(checkedUsersNL).map((checkedUser) => checkedUser.value);
    console.log("checkedUsers: ", checkedUsers);
    if (checkedUsers.length === 0) {
        status.innerText = "please select Users";
    } else {
        // check if selected users already in a group
        const previousChats = conversations.filter((conversation) => checkedUsers.every((checkedUser) => conversation.users.find((convUser) => convUser.id === checkedUser)));
        console.log("previousChat: ", previousChats);
        if (previousChats.length > 0) {
            contentDiv.innerHTML = "";
            // list the group chats and add to ul
            const foundPreviousChatsClone = foundPreviousChatsTemplate.content.cloneNode(true);
            const foundPreviousChatsList = foundPreviousChatsClone.querySelector("#found-chat-list");

            previousChats.forEach(textChat => {
                const textChatListItemClone = textChatListItemTemplate.content.cloneNode(true);
                const li = textChatListItemClone.querySelector("li");
                li.textContent = textChat.name;
                li.dataset.id = textChat.id;
                li.addEventListener("click", () => displayTextChat(textChat.id));
                foundPreviousChatsList.appendChild(textChatListItemClone);
            });

            contentDiv.appendChild(foundPreviousChatsClone);


        } else {
            // set the group chats container to display none;
            try {
                createGroupChatButton.disabled = true;
                status.innerText = "Creating Group Chat..."

                const bodyData = {
                    users: checkedUsers
                }
                const groupConversation = await postRequest("/conversations", bodyData)
                console.log('selected conversation: ', groupConversation.events);

                displayTextChat(groupConversation.id);

            } catch (e) {
                console.log("got an error: ", e);
                createGroupChatButton.disabled = false;
                status.innerText = e;
            }
        }



    }
}


createGroupChatButton.addEventListener("click", () => {

    contentDiv.innerHTML = "";
    const groupChatCreateClone = groupChatCreateTemplate.content.cloneNode(true);
    const groupChatUsers = groupChatCreateClone.querySelector("#group-chat-users");
    const groupChatCreateForm = groupChatCreateClone.querySelector("#group-chat-create-form");
    users.forEach(user => {
        groupChatUsers.innerHTML += ` 
        <div>
          <input type="checkbox" id="${user.id}" name="user" value="${user.id}">
          <label for="${user.id}">${user.display_name}</label>
        </div>`
    });

    groupChatCreateForm.addEventListener("submit", createGroupHandler);
    contentDiv.appendChild(groupChatCreateClone);

});

async function signUp() {
    try {
        const bodyData = {
            name: usernameSignup.value,
            display_name: displayNameSignup.value,
            password: passwordSignup.value
        }
        const data = await postRequest("/signup", bodyData)
        console.log("signUp data: ", data);
        await showDashboard(data);
    } catch (error) {
        console.error("sign up error: ", error);
        displayError(loginSignupStatus, error);
    }
}

signupForm.addEventListener('submit', event => {
    loginSignupStatus.innerText = "";
    event.preventDefault();
    signUp();
});

async function logIn() {
    try {
        const bodyData = {
            name: usernameLogin.value,
            password: passwordLogin.value
        }
        const data = await postRequest("/login", bodyData)
        console.log("log in data: ", data);
        await showDashboard(data);
    } catch (error) {
        console.error("log in error: ", error);
        displayError(loginSignupStatus, error);
    }
}

loginForm.addEventListener('submit', event => {
    loginSignupStatus.innerText = "";
    event.preventDefault();
    logIn();
});
