let NexmoClient = window.NexmoClient;

// console.log('NexmoClient: ', NexmoClient);

// Constants that should from the server
const USER1_JWT = "USER 1 JWT GOES HERE";
const USER2_JWT = "USER 2 JWT GOES HERE";
const CONVERSATION_ID = "CONVERSATION ID GOES HERE";

// Get reference to elements
const username = document.querySelector("#username");
const messageTextarea = document.querySelector("#messageTextarea");
const messageFeed = document.querySelector("#messageFeed");
const sendButton = document.querySelector("#send");
const loginForm = document.querySelector("#login");
const status = document.querySelector("#status");
const messages = document.querySelector("#messages");
const sessionName = document.querySelector("#sessionName");
const loadMessagesButton = document.querySelector("#loadMessages");
const messagesCountSpan = document.querySelector("#messagesCount");
const messageDateSpan = document.querySelector("#messageDate");

// Global variables
let conversation;
let listedEvents;
let messagesCount = 0;
let messageDate;

// Event listeners
loginForm.addEventListener('submit', event => {
    event.preventDefault();
    const userToken = authenticate(username.value);
    console.log('userToken: ',userToken);
    if (userToken) {
        messages.style.display = 'block';
        loginForm.style.display = "none";
        setup(userToken);
    }
});

loadMessagesButton.addEventListener('click', async (event) => {
  // Get next page of events
  let nextEvents = await listedEvents.getNext();
  listMessages(nextEvents);    
});

// authenticate the username DONE ON THE SERVER!
function authenticate(username){
    if (username = "Alice") {
        return USER1_JWT;
    }
    if (username = "Bob") {
        return USER2_JWT;
    }
    alert ("User not recognized!");
};

async function setup(userToken) {
  let client = new NexmoClient({debug: true});
  let app = await client.login(userToken);
  conversation = await app.getConversation(CONVERSATION_ID);

  // Update the UI to show which user we are
  sessionName.textContent = conversation.me.user.name + "'s messages";

  let initialEvents = await conversation.getEvents({ event_type: "text", page_size: 10, order:"desc"});

  // List initial events
  listMessages(initialEvents);

  // Any time there's a new text event, add it as a message
  conversation.on('text', (sender, event) => {
    const formattedMessage = formatMessage(sender, event, conversation.me);
    messageFeed.innerHTML = messageFeed.innerHTML +  formattedMessage;
    // Update UI
    messagesCountSpan.textContent = messagesCount;
  });

  // Listen for clicks on the submit button and send the existing text value
  sendButton.addEventListener('click', async () => {
    await conversation.sendText(messageTextarea.value);
    messageTextarea.value = '';
  });

  // Listen for key presses and send start typing event
  messageTextarea.addEventListener('keypress', (event) => {
    conversation.startTyping();
  });
  
  // Listen for when typing stops and send an event
  let timeout = null;
  messageTextarea.addEventListener('keyup', (event) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      conversation.stopTyping();
    }, 500);
  });

  // When there is a typing event, display an indicator
  conversation.on("text:typing:on", (data) => {
    if (data.user.id !== data.conversation.me.user.id) {
      status.textContent = data.user.name + " is typing...";
    }
  });

  // When typing stops, clear typing indicator
  conversation.on("text:typing:off", (data) => {
    status.textContent = "";
  });
}

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