const NexmoClient = window.NexmoClient;

console.log('window NexmoClient: ', NexmoClient);

const BASE_URL = "https://v-app-companion.herokuapp.com";
// const BASE_URL = "https://abdulajet.ngrok.io"



// Constants that should from the server
// const USER1_JWT = "USER 1 JWT GOES HERE";
// const USER2_JWT = "USER 2 JWT GOES HERE";
// const CONVERSATION_ID = "CONVERSATION ID GOES HERE";

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

const selectedUserProfileTemplate = document.querySelector("#selected-user-profile-template");

const settingsDiv = document.querySelector("#settings");
const settingsTemplate = document.querySelector("#settings-template");

// Global variables
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

async function postRequest(endpoint= "", data = {}){
    try {
        const response = await fetch(BASE_URL + endpoint, {
            method: 'POST', // *GET, POST, PUT, DELETE, etc.
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data) // body data type must match "Content-Type" header
        });
        if (!response.ok) {
            throw await response.json();
        }
        return response.json();

    } catch(error) {
        console.error("postRequest error: ", error);
        throw error;
        // return error;
    }
}

function displayError(element, error){
    let errorText = "Error: ";
    if (error.type === "data:validation"){
        errorText += "<ul>"
        for (let i=0; i < error.invalid_parameters.length; i++){
            errorText += `<li>${error.invalid_parameters[i].name} ${error.invalid_parameters[i].reason} </li>`;
        }
        errorText += "</ul>"
    } else {
        errorText += error.detail;
    }
    element.innerHTML = errorText;
}

function callButtonClickHandler(e){
    console.log("callButtonClickHandler: ",e.target.dataset.username);
    app.callServer(e.target.dataset.username,"app").then((nxmCall) => {
        // app.inAppCall([e.target.dataset.username]).then((nxmCall) => {
        console.log('Calling user(s)...', nxmCall);
        currentCall = nxmCall;
        // callServerHangUpButton.addEventListener("click", ()=>{
        //     nxmCall.hangUp({reason_code:'404', reason_text:'User hung up'}).then((event) => {
        //         console.log('hang up event', event);
        //     }).catch((error) => {
        //         console.error(error);
        //     });
        // })

    }).catch((error) => {
        console.error(error);
    });
}

function hangupButtonClickHandler(){
    currentCall.hangUp({reason_code:'404', reason_text:'User hung up'}).then((event) => {
        console.log('hang up event', event);
    }).catch((error) => {
        console.error(error);
    });
}


function answerCallHandler(caller){
    console.log("answerCallHandler caller: ", caller);
    contentDiv.innerHTML = "";
    const selectedUserProfileClone = selectedUserProfileTemplate.content.cloneNode(true);
    const img = selectedUserProfileClone.querySelector("img");
    const name = selectedUserProfileClone.querySelector("#display-name");
    const callButton = selectedUserProfileClone.querySelector("#call-user");
    callButton.dataset.username = caller.name;
    callButton.style.display = "none";
    const hangupButton = selectedUserProfileClone.querySelector("#hangup-user");
    img.src = caller.image_url === null ? `https://robohash.org/${caller.name}` : caller.image_url;
    name.innerText = caller.display_name;
    callButton.addEventListener("click", callButtonClickHandler);
    hangupButton.addEventListener("click", hangupButtonClickHandler);
    contentDiv.appendChild(selectedUserProfileClone);

}

function userClickHandler(e) {
    contentDiv.innerHTML = "";
    console.log("userClickHandler: ", e.target.innerText);
    console.log("userClickHandler: ", e.target.dataset.username);
    console.log("userClickHandler: ", e.target.dataset.userId);
    console.log("userClickHandler: ", e.target.dataset.userProfileImage);
    const selectedUserProfileClone = selectedUserProfileTemplate.content.cloneNode(true);
    const img = selectedUserProfileClone.querySelector("img");
    const name = selectedUserProfileClone.querySelector("#display-name");
    const callButton = selectedUserProfileClone.querySelector("#call-user");
    callButton.dataset.username = e.target.dataset.username;
    const hangupButton = selectedUserProfileClone.querySelector("#hangup-user");
    hangupButton.style.display = "none";
    img.src = e.target.dataset.userProfileImage === "null" ? `https://robohash.org/${e.target.dataset.username}` : e.target.dataset.userProfileImage;
    name.innerText = e.target.innerText;
    callButton.addEventListener("click", callButtonClickHandler);
    hangupButton.addEventListener("click", hangupButtonClickHandler);
    contentDiv.appendChild(selectedUserProfileClone);
}

function logoutClickHandler(e) {
    console.log("logout!");
}


// Set up Vonage Application
async function setupApplication(){
    try {
        const client = new NexmoClient({debug:false});
        app = await client.login(jwt);
        console.log('app: ',app);

        app.on("call:status:changed", (nxmCall) => {
            console.log('call:status:changed nxmCall: ', nxmCall);
            const callButton = document.querySelector("#call-user");
            const hangupButton = document.querySelector("#hangup-user");
            const callStatus = document.querySelector("#call-status");
            if (callStatus){
                callStatus.innerText = nxmCall.status
            }
            // call = nxmCall;
            if (callButton || hangupButton){
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
            // This is a test to see if I can call a person on a phone from the app and connect another application user
            // conv = nxmCall.conversation;
            // console.log('conv: ', conv);
        });

        app.on("member:call", (member, nxmCall) => {
            console.log("member:call member: ", member);
            console.log("member:call NXMCall answer: ", nxmCall);
            currentCall = nxmCall;
            //Get other member of conversation
            let otherMember;
            for (let [key, value] of nxmCall.conversation.members) {
                if (key !== member.id){
                    console.log('other member: ', value);
                    otherMember = value;
                    // otherMemberSetup();
                }
            }

            if (member.state === "INVITED"){
                // Need this for inAppCall & callSever doesn't send member.invited_by
                if (!member.initiator.invited.isSystem){
                    if (window.confirm(`Accept invite from ${member.invited_by}?`)) {
                        nxmCall.answer();
                        //display onGoingCall template
                    } else {
                        nxmCall.reject({reason_code:'403', reason_text:'User turned down request'}).then(() => {
                            console.log('Call rejected.');
                        }).catch((error) => {
                            console.error(error);
                        });
                    }
                    // inAppHangUpButton.addEventListener("click", ()=>{
                    //     nxmCall.hangUp({reason_code:'404', reason_text:'User hung up'}).then(() => {
                    //         console.log('Call hung up.');
                    //     }).catch((error) => {
                    //         console.error(error);
                    //     });
                    // })

                } else {
                    console.log("myUser: ", myUser);
                    console.log("users: ", users);
                    const otherUser = users.find(user => otherMember.user.id === user.id);
                    if (window.confirm(`Join audio call with ${otherMember.display_name}?`)) {
                        nxmCall.answer();
                        answerCallHandler(otherUser);

                    } else {
                        nxmCall.reject({reason_code:'403', reason_text:'User turned down request'}).then(() => {
                            console.log('Call rejected.');
                        }).catch((error) => {
                            console.error(error);
                        });
                    }
                    // callServerHangUpButton.addEventListener("click", ()=>{
                    //     nxmCall.hangUp({reason_code:'404', reason_text:'User hung up'}).then(() => {
                    //         console.log('Call hung up.');
                    //     }).catch((error) => {
                    //         console.error(error);
                    //     });
                    // })

                }

            }


        });

        // app.on("member:invited",(member, event) => {
        //     console.log("member:invited member: ", member);
        //     // otherMember = member;
        //     console.log("my member id: ",member.id);
        //     console.log("member:invited event: ", event);
        //     //Get other member of conversation
        //     for (let [key, value] of event.conversation.members) {
        //         if (key !== member.id){
        //             console.log('other member: ', value);
        //             // otherMember = value;
        //             // otherMemberSetup();
        //         }
        //     }
        //     // console.log("Invited to the conversation: " + event.conversation.display_name || event.conversation.name);
        //     console.log("Invited to the conversation display_name: " + event.conversation.display_name);
        //     console.log("Invited to the conversation: name" + event.conversation.name);
        //     // identify the sender.
        //     console.log("Invited by: " + member.invited_by);
        //     // **May not need this**Need this for callServer. Looks like it doesn't say who is the invite from
        //     if (event.conversation.display_name.includes('CONV_')){
        //         if (window.confirm(`Join conversation chat with ${member.invited_by}`)){
        //             //accept an invitation.
        //             // conv = event.conversation;
        //             app.conversations.get(event.conversation.id).join();
        //         } else {
        //             //decline the invitation.
        //             app.conversations.get(event.conversation.id).leave();
        //         }
        //         // callServerHangUpButton.addEventListener("click", ()=>{
        //         //   app.conversations.get(event.conversation.id).leave();
        //         // })
        //     }
        // });


        return;
    }
    catch (error){
        console.error('error in setup: ', error);
        return;
    }

}


async function showDashboard(data){
    console.log("showDashboard: ", data);
    tabFocus = 2;
    // tabs[2].setAttribute("tabindex", 0);
    // tabs[2].focus();

    loginSignUpSection.style.display = "none";
    myUser = data.user;
    conversations = data.conversations;
    jwt = data.token;
    await setupApplication();
    users = data.users.sort(function(a, b) {
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

    users.forEach(user =>{
        const userClone = usersListItemTemplate.content.cloneNode(true);
        const button = userClone.querySelector("button");
        button.textContent = user.display_name;
        button.dataset.userId = user.id;
        button.dataset.username = user.name;
        button.dataset.userProfileImage = user.image_url;
        button.addEventListener("click", userClickHandler);
        usersList.appendChild(userClone);
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

function createNewChat(){}

async function signUp(){
    try {
        const bodyData = {
            name: usernameSignup.value,
            display_name: displayNameSignup.value,
            password: passwordSignup.value
        }
        const data = await postRequest("/signup",bodyData)
        console.log("signUp data: ", data);
        await showDashboard(data);
    } catch(error) {
        console.error("sign up error: ", error);
        displayError(loginSignupStatus, error);
    }
}

signupForm.addEventListener('submit', event => {
    loginSignupStatus.innerText = "";
    event.preventDefault();
    signUp();
});

async function logIn(){
    try {
        const bodyData = {
            name: usernameLogin.value,
            password: passwordLogin.value
        }
        const data = await postRequest("/login",bodyData)
        console.log("log in data: ", data);
        await showDashboard(data);
    } catch(error) {
        console.error("log in error: ", error);
        displayError(loginSignupStatus, error);
    }
}

loginForm.addEventListener('submit', event => {
    loginSignupStatus.innerText = "";
    event.preventDefault();
    logIn();
    // const userToken = authenticate(username.value);
    // console.log('userToken: ',userToken);
    // if (userToken) {
    //     messages.style.display = 'block';
    //     loginForm.style.display = "none";
    //     setup(userToken);
    // }
});


// loadMessagesButton.addEventListener('click', async (event) => {
//   // Get next page of events
//   let nextEvents = await listedEvents.getNext();
//   listMessages(nextEvents);
// });

// // authenticate the username DONE ON THE SERVER!
// function authenticate(username){
//     if (username = "Alice") {
//         return USER1_JWT;
//     }
//     if (username = "Bob") {
//         return USER2_JWT;
//     }
//     alert ("User not recognized!");
// };

// async function setup(userToken) {
//   let client = new NexmoClient({debug: true});
//   let app = await client.login(userToken);
//   conversation = await app.getConversation(CONVERSATION_ID);
//
//   // Update the UI to show which user we are
//   sessionName.textContent = conversation.me.user.name + "'s messages";
//
//   let initialEvents = await conversation.getEvents({ event_type: "text", page_size: 10, order:"desc"});
//
//   // List initial events
//   listMessages(initialEvents);
//
//   // Any time there's a new text event, add it as a message
//   conversation.on('text', (sender, event) => {
//     const formattedMessage = formatMessage(sender, event, conversation.me);
//     messageFeed.innerHTML = messageFeed.innerHTML +  formattedMessage;
//     // Update UI
//     messagesCountSpan.textContent = messagesCount;
//   });
//
//   // Listen for clicks on the submit button and send the existing text value
//   sendButton.addEventListener('click', async () => {
//     await conversation.sendText(messageTextarea.value);
//     messageTextarea.value = '';
//   });
//
//   // Listen for key presses and send start typing event
//   messageTextarea.addEventListener('keypress', (event) => {
//     conversation.startTyping();
//   });
//
//   // Listen for when typing stops and send an event
//   let timeout = null;
//   messageTextarea.addEventListener('keyup', (event) => {
//     clearTimeout(timeout)
//     timeout = setTimeout(() => {
//       conversation.stopTyping();
//     }, 500);
//   });
//
//   // When there is a typing event, display an indicator
//   conversation.on("text:typing:on", (data) => {
//     if (data.user.id !== data.conversation.me.user.id) {
//       status.textContent = data.user.name + " is typing...";
//     }
//   });
//
//   // When typing stops, clear typing indicator
//   conversation.on("text:typing:off", (data) => {
//     status.textContent = "";
//   });
// }

function listMessages(events) {
    // console.log(events);
    let listMessages = "";
    if (events.hasNext()) {
        loadMessagesButton.style.display = "block";
    } else {
        loadMessagesButton.style.display = "none";
    };

    // Replace current with new page of events
    listedEvents = events;

    events.items.forEach(event => {
        console.log("event: ",event);
        const formattedMessage = formatMessage(conversation.members.get(event.from), event, conversation.me);
        listMessages = formattedMessage + listMessages;
    });

    //Update the UI
    messageFeed.innerHTML = listMessages + messageFeed.innerHTML;
    messagesCountSpan.textContent = messagesCount;
    messageDateSpan.textContent = messageDate;
};

function formatMessage(sender, message, me){
    const rawDate = new Date(Date.parse(message.timestamp));
    const options ={ weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric' };
    const formattedDate = rawDate.toLocaleDateString(undefined,options);
    let text = '';
    messagesCount++;
    messageDate = formattedDate;
    if(message.from !== me.id) {
        text = `<span style="color:red">${sender.user.name} (${formattedDate}): <b>${message.body.text}</b></span>`;
    } else {
        text = `<span>me (${formattedDate}): <b>${message.body.text}</b></span>`;
    }
    return text + '<br />';
}