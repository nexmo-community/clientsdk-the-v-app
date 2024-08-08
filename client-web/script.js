const BASE_URL = "VAPP_BASE_URL";

// Get reference to elements
const messageTextarea = document.querySelector('#messageTextarea');
const messageFeed = document.querySelector('#messageFeed');
const sendButton = document.querySelector('#send');
const status = document.querySelector('#status');
const messages = document.querySelector('#messages');
const sessionName = document.querySelector('#sessionName');
const loadMessagesButton = document.querySelector('#loadMessages');
const messagesCountSpan = document.querySelector('#messagesCount');
const messageDateSpan = document.querySelector('#messageDate');

const loginSignUpSection = document.querySelector('#login-signup');

const loginForm = document.querySelector('#login');
const usernameLogin = document.querySelector('#username-login');
const passwordLogin = document.querySelector('#password-login');

const signupForm = document.querySelector('#signup');
const usernameSignup = document.querySelector('#username-signup');
const displayNameSignup = document.querySelector('#display-name-signup');
const passwordSignup = document.querySelector('#password-signup');

const loginSignupStatus = document.querySelector('#login-signup-status');

const dashboardSection = document.querySelector('#dashboard');
const contentDiv = document.querySelector('#content');
const chatContainerDiv = document.querySelector('#chat-container');

const usersList = document.querySelector('#users-list');
const usersListItemTemplate = document.querySelector(
  '#users-list-item-template'
);

const textChatListConversations = document.querySelector(
  '#text-chat-list-conversations'
);
const textChatListInvites = document.querySelector('#text-chat-list-invites');
const textChatListItemTemplate = document.querySelector(
  '#text-chat-list-item-template'
);

const selectedUserProfileTemplate = document.querySelector(
  '#selected-user-profile-template'
);

const settingsDiv = document.querySelector('#settings');
const settingsTemplate = document.querySelector('#settings-template');

const textChatTemplate = document.querySelector('#text-chat-template');

const chatContainer = document.querySelector('#chat-container');
const vonageInput = document.querySelector('vc-text-input');
const vonageTypingIndicator = document.querySelector('vc-typing-indicator');
const vonageMembers = document.querySelector('vc-members');
const vonageMessagesFeed = document.querySelector('vc-messages');
const imageUploadInput = document.querySelector('#image-message');

const groupChatCreateTemplate = document.querySelector(
  '#group-chat-create-template'
);
const createGroupChatButton = document.querySelector('#create-group-chat');

const foundPreviousChatsTemplate = document.querySelector(
  '#found-previous-chats-template'
);

const tab3 = document.querySelector('#tab-3');
const tab4 = document.querySelector('#tab-4');
const tab5 = document.querySelector('#tab-5');

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
let callId;

let currentConversationId;

let callButton;
let hangupButton;

// adds sending chat messages with Enter key
vonageInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter' || e.keyCode === 13) {
    vonageInput.__handleClickEvent();
  }
});

function iconOrTextTab() {
  if (window.innerWidth > 950) {
    tab3.innerText = 'Chats';
    tab4.innerText = 'Contacts';
    tab5.innerText = 'Settings';
  } else {
    tab3.innerText = '💬';
    tab4.innerText = '👥';
    tab5.innerText = '⚙️';
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
    .forEach((t) => t.setAttribute('aria-selected', false));

  // Set this tab as selected
  target.setAttribute('aria-selected', true);

  // Hide all tab panels
  grandparent
    .querySelectorAll('[role="tabpanel"]')
    .forEach((p) => p.setAttribute('hidden', true));

  // Show the selected panel
  grandparent.parentNode
    .querySelector(`#${target.getAttribute('aria-controls')}`)
    .removeAttribute('hidden');
}

// Add a click event handler to each tab
tabs.forEach((tab) => {
  tab.addEventListener('click', changeTabs);
});

// Enable arrow navigation between tabs in the tab list
let tabFocus = 0;

tabLists.forEach((tabList) => {
  tabList.addEventListener('keydown', (e) => {
    // Move right
    if (e.keyCode === 39 || e.keyCode === 37) {
      tabs[tabFocus].setAttribute('tabindex', -1);
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
      tabs[tabFocus].setAttribute('tabindex', 0);
      tabs[tabFocus].focus();
    }
  });
});

async function postRequest(endpoint = '', data = {}) {
  try {
    const response = await fetch(BASE_URL + endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${jwt}`,
        'Bypass-Tunnel-Reminder': true, // used for localtunnel only
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    if (!response.ok) {
      throw await response.json();
    }
    return response.json();
  } catch (error) {
    console.error('postRequest error: ', error);
    throw error;
  }
}

async function upload(formData, endpoint = '') {
  try {
    const response = await fetch(BASE_URL + endpoint, {
      method: 'POST',
      headers: {
        // 'Content-Type': 'multipart/form-data',
        Authorization: `Bearer ${jwt}`,
        'Bypass-Tunnel-Reminder': true, // used for localtunnel only
      },
      body: formData, // body data type must match "Content-Type" header
    });
    if (!response.ok) {
      throw await response.json();
    }
    return response.json();
  } catch (error) {
    console.error('postRequest error: ', error);
    throw error;
  }
}

function displayError(element, error) {
  let errorText = 'Error: ';
  if (error.type === 'data:validation') {
    errorText += '<ul>';
    for (let i = 0; i < error.invalid_parameters.length; i++) {
      errorText += `<li>${error.invalid_parameters[i].name} ${error.invalid_parameters[i].reason} </li>`;
    }
    errorText += '</ul>';
  } else {
    errorText += error.detail;
  }
  element.innerHTML = errorText;
}

function callButtonClickHandler(e) {
  callButton.innerText = 'Calling...';
  callButton.disabled = true;
  client
    .serverCall({
      to: e.target.dataset.username,
      custom_data: { from: 'V-app web' },
    })
    .then((_callId) => {
      callId = _callId;
    })
    .catch((error) => {
      console.error('Error making call: ', error);
    });
}

function hangupButtonClickHandler() {
  client
    .hangup(callId)
    .then(() => {
      hangupButton.style.display = 'none';
      callButton.style.display = 'inline';
    })
    .catch((error) => {
      console.error('Error hanging up call: ', error);
    });
}

function showSelectedUser(user, answeringCall = false) {
  const username = answeringCall ? user.name : user.target.dataset.username;
  let profileImage = answeringCall
    ? user.image_url
    : user.target.dataset.userProfileImage;
  const displayName = answeringCall ? user.display_name : user.target.innerText;
  const userId = answeringCall ? user.id : user.target.dataset.userId;

  if (
    profileImage === null ||
    profileImage === 'null' ||
    profileImage === undefined ||
    profileImage === 'undefined'
  ) {
    profileImage = `https://robohash.org/${username}`;
  }

  contentDiv.innerHTML = '';

  const selectedUserProfileClone =
    selectedUserProfileTemplate.content.cloneNode(true);
  const img = selectedUserProfileClone.querySelector('img');
  const name = selectedUserProfileClone.querySelector('#display-name');
  callButton = selectedUserProfileClone.querySelector('#call-user');
  callButton.dataset.username = username;
  hangupButton = selectedUserProfileClone.querySelector('#hangup-user');
  if (answeringCall) {
    callButton.style.display = 'none';
  } else {
    hangupButton.style.display = 'none';
  }
  img.src = profileImage;
  name.innerText = displayName;
  callButton.addEventListener('click', callButtonClickHandler);
  hangupButton.addEventListener('click', hangupButtonClickHandler);
  contentDiv.appendChild(selectedUserProfileClone);
  chatContainerDiv.style.display = 'none';
  contentDiv.style.display = 'block';
}

function logoutClickHandler(e) {
  client
    .deleteSession()
    .then((response) => {
      settingsDiv.innerHTML = '';
      usersList.innerHTML = '';
      contentDiv.innerHTML =
        "<div class='center'><img src='./VonageLogo_Primary_White-500px.png' /></div>";
      dashboardSection.style.display = 'none';
      loginSignUpSection.style.display = 'flex';
    })
    .catch((error) => {
      console.error('logout error: ', error);
    });
}

// Set up Vonage Application
async function setupApplication() {
  try {
    client = new vonageClientSDK.VonageClient();

    const sessionId = await client.createSession(jwt);

    const params = {
      order: 'asc', // "desc"
      pageSize: 100,
      cursor: null,
      includeCustomData: true,
      orderBy: null, // "CUSTOM_SORT_KEY"
    };

    client
      .getConversations(params)
      .then(({ conversations: _conversations, nextCursor, previousCursor }) => {
        conversations = _conversations;
      })
      .catch((error) => {
        console.error('Error getting Conversations: ', error);
      });

    client.on('conversationEvent', (event) => {
      if (event.body.channel.id === null) {
        switch (event.kind) {
          case 'member:invited':
            updateTextChats();
            break;
          case 'member:joined':
            updateTextChats();
            break;
          case 'member:left':
            updateTextChats();
            break;
          default:
            console.log('default event: ', event);
        }
      }
    });

    client.on('callInvite', (_callId, from) => {
      callId = _callId;
      const otherUser = users.find((user) => from === user.name);
      if (window.confirm(`Join audio call with ${otherUser.display_name}?`)) {
        showSelectedUser(otherUser, true);
        client
          .answer(callId)
          .then(() => {})
          .catch((error) => {
            console.error('Error answering call: ', error);
          });
      } else {
        client
          .reject(callId)
          .then(() => {})
          .catch((error) => {
            console.error('Error rejecting call: ', error);
          });
      }
    });

    client.on('legStatusUpdate', (callId, legId, status) => {
      callButton.innerText = 'Call';
      callButton.disabled = false;
      if (status === 'ANSWERED') {
        callButton.style.display = 'none';
        hangupButton.style.display = 'inline';
      }
      if (status === 'COMPLETED') {
        hangupButton.style.display = 'none';
        callButton.style.display = 'inline';
      }
    });

    client.on('callHangup', (callId, callQuality, reason) => {
      callId = null;
      hangupButton.style.display = 'none';
      callButton.style.display = 'inline';
    });

    client.on('sessionError', async (error) => {
      //get a refresh token
      try {
        const bodyData = {
          name: usernameLogin.value,
          password: passwordLogin.value,
        };
        const data = await postRequest('/token', bodyData);
        jwt = data.token;
        await client.createSession(jwt);
      } catch (error) {
        console.error('log in error: ', error);
        displayError(loginSignupStatus, error);
      }
    });
    return;
  } catch (error) {
    console.error('error in setup: ', error);
    return;
  }
}

async function handleImageUploadInputChange() {
  const formData = new FormData();
  formData.append('image', imageUploadInput.files[0]);
  try {
    const uploadResponse = await upload(formData, '/image');
    imageUploadInput.value = null;
    const timestamp = await client.sendMessageImageEvent(
      currentConversationId,
      uploadResponse.image_url
    );
  } catch (error) {
    console.error('Error sending image message: ', error);
  }
}

async function displayTextChat(selectedConversationId) {
  currentConversationId = selectedConversationId;
  vonageInput.client = client;
  vonageInput.conversationId = selectedConversationId;

  vonageTypingIndicator.client = client;
  vonageTypingIndicator.conversationId = selectedConversationId;

  vonageMembers.client = client;
  vonageMembers.conversationId = selectedConversationId;

  vonageMessagesFeed.client = client;
  vonageMessagesFeed.conversationId = selectedConversationId;

  contentDiv.style.display = 'none';

  chatContainerDiv.style.display = 'block';

  // handling profile image file input
  imageUploadInput.removeEventListener('change', handleImageUploadInputChange);
  imageUploadInput.addEventListener('change', handleImageUploadInputChange);
}

async function joinAndDisplayTextChat(invitedConversationId) {
  // Join conversation
  try {
    await client.joinConversation(invitedConversationId);
    displayTextChat(invitedConversationId);
  } catch (e) {
    console.error('error joining conversation: ', e);
  }
}

async function leaveTextChat(leaveConversationId) {
  // Leave conversation
  try {
    await client.leaveConversation(leaveConversationId);
    // if you leave a conversation you have open, clear the text chat
    if (leaveConversationId === currentConversationId) {
      chatContainerDiv.style.display = 'none';
      contentDiv.style.display = 'block';
    }
    updateTextChats();
  } catch (e) {
    console.error('error leaving conversation: ', e);
  }
}

async function updateTextChats() {
  const params = {
    order: 'asc', // "desc"
    pageSize: 100,
    cursor: null,
    includeCustomData: true,
    orderBy: null, // "CUSTOM_SORT_KEY"
  };

  const { conversations: textChats } = await client.getConversations(params);
  textChatListConversations.innerHTML = '';
  textChatListInvites.innerHTML = '';
  textChats.forEach((textChat) => {
    const textChatListItemClone =
      textChatListItemTemplate.content.cloneNode(true);
    const li = textChatListItemClone.querySelector('li');
    li.textContent = textChat.name;
    if (textChat.memberState === 'JOINED') {
      li.innerHTML = `${textChat.displayName} <br> <button onclick="displayTextChat('${textChat.id}')">Open</button>  <button onclick="leaveTextChat('${textChat.id}')">Leave</button> `;
      li.dataset.id = textChat.id;
      textChatListConversations.appendChild(textChatListItemClone);
    } else if (textChat.memberState === 'INVITED') {
      li.innerHTML = `${textChat.displayName} <br> <button onclick="joinAndDisplayTextChat('${textChat.id}')">Join</button>  <button onclick="leaveTextChat('${textChat.id}')">Reject</button> `;
      li.dataset.id = textChat.id;
      textChatListInvites.appendChild(textChatListItemClone);
    }
  });
}

async function showDashboard(data) {
  tabFocus = 2;
  loginSignUpSection.style.display = 'none';
  myUser = data.user;
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

  users.forEach((user) => {
    const userClone = usersListItemTemplate.content.cloneNode(true);
    const button = userClone.querySelector('button');
    button.textContent = user.display_name;
    button.dataset.userId = user.id;
    button.dataset.username = user.name;
    button.dataset.userProfileImage = user.image_url;
    button.addEventListener('click', showSelectedUser);
    usersList.appendChild(userClone);
  });

  updateTextChats();

  // Set up Settings tab
  const settingsClone = settingsTemplate.content.cloneNode(true);
  const settingsImg = settingsClone.querySelector('img');
  const settingsDisplayName = settingsClone.querySelector('#user-display-name');
  const settingLogoutButton = settingsClone.querySelector('#logout');

  // update profile picture
  const profileImageForm = settingsClone.querySelector('#profile-image-form');
  const profileImageFileInput = settingsClone.querySelector('#image-file');
  const imageUploadStatus = settingsClone.querySelector('#image-upload-status');

  // check if an image was uploaded
  if (myUser.image_url) {
    settingsImg.src = myUser.image_url;
  } else {
    settingsImg.src = `https://robohash.org/${myUser.name}`;
  }
  settingsDisplayName.innerText = myUser.display_name;
  settingLogoutButton.addEventListener('click', logoutClickHandler);

  // handling profile image file input
  profileImageFileInput.addEventListener('change', async () => {
    imageUploadStatus.textContent = 'starting...';
    const formData = new FormData();
    formData.append('image', profileImageFileInput.files[0]);

    try {
      imageUploadStatus.textContent = 'updating...';
      const uploadResponse = await upload(formData, '/users/image');
      settingsImg.src = uploadResponse.image_url;
      profileImageFileInput.value = null;
      imageUploadStatus.textContent = 'success!';
      setTimeout(() => {
        imageUploadStatus.textContent = '';
      }, 3000);
    } catch (error) {
      console.error('Error setting user image: ', error);
    }
  });

  settingsDiv.appendChild(settingsClone);
  dashboardSection.style.display = 'flex';
}

async function createGroupHandler(e) {
  e.preventDefault();
  const createGroupChatButton = document.querySelector(
    '#group-chat-create-button'
  );
  const chatDisplayNameInput = document.querySelector('#chat-display-name');
  const status = document.querySelector('#group-chat-status');
  status.innerText = '';
  const checkedUsersNL = document.querySelectorAll(
    'input[name="user"]:checked'
  );
  const checkedUsers = Array.from(checkedUsersNL).map(
    (checkedUser) => checkedUser.value
  );
  if (checkedUsers.length === 0) {
    status.innerText = 'please select Users';
  } else if (
    chatDisplayNameInput.value === null ||
    chatDisplayNameInput.value === ''
  ) {
    status.innerText = 'please enter chat name';
  } else {
    try {
      createGroupChatButton.disabled = true;
      status.innerText = 'Creating Group Chat...';

      // create a conversation
      const params = {
        displayName: chatDisplayNameInput.value,
        ttl: null, // 600 (in seconds)
        customData: { users: [myUser.name, ...checkedUsers] },
      };

      const conversationId = await client.createConversation(params);

      // Join yourself to the conversation
      status.innerText = 'Joining Conversation...';

      const myMemberId = await client.joinConversation(conversationId);

      // Invite other User to the conversation
      status.innerText = `Inviting users...`;
      checkedUsers.forEach(async (element) => {
        await client.inviteToConversation(conversationId, element);
      });

      status.innerText = 'Success!';
      setTimeout(() => {
        status.innerText = '';
      }, 3000);

      displayTextChat(conversationId);
      updateTextChats();
    } catch (e) {
      createGroupChatButton.disabled = false;
      status.innerText = e;
    }
  }
}

createGroupChatButton.addEventListener('click', () => {
  contentDiv.innerHTML = '';
  const groupChatCreateClone = groupChatCreateTemplate.content.cloneNode(true);
  const groupChatUsers =
    groupChatCreateClone.querySelector('#group-chat-users');
  const groupChatCreateForm = groupChatCreateClone.querySelector(
    '#group-chat-create-form'
  );
  users.forEach((user) => {
    groupChatUsers.innerHTML += ` 
        <div>
          <input type="checkbox" id="${user.name}" name="user" value="${user.name}">
          <label for="${user.name}">${user.display_name}</label>
        </div>`;
  });

  groupChatCreateForm.addEventListener('submit', createGroupHandler);
  contentDiv.appendChild(groupChatCreateClone);
  chatContainerDiv.style.display = 'none';
  contentDiv.style.display = 'block';
});

async function signUp() {
  try {
    const bodyData = {
      name: usernameSignup.value,
      display_name: displayNameSignup.value,
      password: passwordSignup.value,
    };
    const data = await postRequest('/signup', bodyData);
    await showDashboard(data);
  } catch (error) {
    console.error('sign up error: ', error);
    displayError(loginSignupStatus, error);
  }
}

signupForm.addEventListener('submit', (event) => {
  loginSignupStatus.innerText = '';
  event.preventDefault();
  signUp();
});

async function logIn() {
  const loginButton = document.querySelector('#login button');
  try {
    loginButton.disabled = true;
    loginButton.innerText = 'Logging In...';
    const bodyData = {
      name: usernameLogin.value,
      password: passwordLogin.value,
    };
    const data = await postRequest('/login', bodyData);
    await showDashboard(data);
    loginButton.disabled = false;
    loginButton.innerText = 'Log In';
    usernameLogin.value = '';
    passwordLogin.value = '';
  } catch (error) {
    console.error('log in error: ', error);
    loginButton.disabled = false;
    loginButton.innerText = 'Log In';
    displayError(loginSignupStatus, error);
  }
}

loginForm.addEventListener('submit', (event) => {
  loginSignupStatus.innerText = '';
  event.preventDefault();
  logIn();
});
