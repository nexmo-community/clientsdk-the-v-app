# "The V-app" Server

The server sits between the clients and the [Vonage Conversation API](https://developer.vonage.com/conversation/overview) to handle authentication and conversation-related utilities.

## Endpoints:

### Authentication

<details>
    <summary>Sign Up</summary>

This creates an account for the user and returns information needed to start the client, including a JWT.

**Endpoint:** `/signup`

**Method:** `POST`

**Headers:** `'Content-Type: application/json'`

**Request Body:**

| Key | Type | Required | 
|-----|------|----------|
`name` | string | ✓
`password` | string | ✓
`display_name` | string | ✓

**Response:**

Success (201):
```
{
  "user": {
    "id": "USR-44326d04-cd82-41f5-ad24-315c2a2eac41",
    "name": "paul",
    "display_name": "paul"
  },
  "token": "ey...dg",
  "users": [
    {
      "id": "USR-f6145cd9-eacf-4f11-bfb2-d36cf8bbe85c",
      "name": "arden-399b3400-b0c4-4b9c-8e93-09acb7865c50",
      "display_name": "Amos Jenkins"
    },
    ...
  ],
  "conversations": [
    {
      "state": "ACTIVE",
      "created_at": "2021-03-15T15:56:34.749Z",
      "id": "CON-8135548f-066e-4525-af9f-2be0138409e8",
      "users": [
        {
          "id": "USR-43462453-b3be-4e01-9d3c-5f2525bc79d5",
          "name": "dwane",
          "display_name": "dwane",
          "state": "JOINED"
        }
      ],
      "name": "dwane",
      "joined_at": "2021-03-15T15:56:35.163Z"
    },
    ...
  ]
}
```

Error (403):
```
{
  "type": "data:validation",
  "title": "Bad Request",
  "detail": "The request failed due to validation errors",
  "invalid_parameters": [
    {
      "name": "name",
      "reason": "must be longer than 2 characters"
    }
  ]
}
```
</details>

<details>
    <summary>Log In</summary>

Called after a user account has been created by signing up, this returns information needed to start the client, including a JWT.

**Endpoint:** `/login`

**Method:** `POST`

**Headers:** `'Content-Type: application/json'`

**Request Body:**

| Key | Type | Required | 
|-----|------|----------|
`name` | string | ✓
`password` | string | ✓

**Response:**

Success (200):
```
{
  "user": {
    "id": "USR-44326d04-cd82-41f5-ad24-315c2a2eac41",
    "name": "paul",
    "display_name": "paul"
  },
  "token": "ey...dg",
  "users": [
    {
      "id": "USR-f6145cd9-eacf-4f11-bfb2-d36cf8bbe85c",
      "name": "arden-399b3400-b0c4-4b9c-8e93-09acb7865c50",
      "display_name": "Amos Jenkins"
    },
    ...
  ],
  "conversations": [
    {
      "state": "ACTIVE",
      "created_at": "2021-03-15T15:56:34.749Z",
      "id": "CON-8135548f-066e-4525-af9f-2be0138409e8",
      "users": [
        {
          "id": "USR-43462453-b3be-4e01-9d3c-5f2525bc79d5",
          "name": "dwane",
          "display_name": "dwane",
          "state": "JOINED"
        }
      ],
      "name": "dwane",
      "joined_at": "2021-03-15T15:56:35.163Z"
    },
    ...
  ]
}
```

Error (403):
```
{
  "type": "auth:unauthorized",
  "title": "Bad Request",
  "detail": "The request failed due to invalid credentials"
}
```
</details>
</br>

### Users

<details>
    <summary>Get Users</summary>

This returns a list of other users one can have a conversation with (excluding the requesting user). A JWT is required in the request's header.


**Endpoint:** `/users`

**Method:** `GET`

**Headers:** 

`'Authorization: Bearer $JWT'`

**Response:**

Success (200):
```
[
  {
    "id": "USR-9665b809-565f-486b-974c-f39881953240",
    "name": "edward-1a3f09b0-51ca-444d-ba5d-186588826840",
    "display_name": "Rev. Rolando Johnston"
  },
  ...
]
```

Error (403):
```
{
  "type": "auth:unauthorized",
  "title": "Bad Request",
  "detail": "The request failed due to invalid credentials"
}
```
</details>
</br>

### Conversations

<details>
    <summary>Get Conversations</summary>

This returns a list of conversations a user is a part of. A JWT is required in the request's header.

**Endpoint:** `/conversations`

**Method:** `GET`

**Headers:** 

`'Authorization: Bearer $JWT'`

**Response:**

Success (200):
```
[
  {
    "state": "ACTIVE",
    "created_at": "2021-03-15T15:49:01.029Z",
    "id": "CON-dae195ea-e3c3-4560-9de7-cb30a4c0b6e1",
    "users": [
      {
        "id": "USR-43462453-b3be-4e01-9d3c-5f2525bc79d5",
        "name": "dwane",
        "display_name": "dwane",
        "state": "JOINED"
      }
    ],
    "name": "dwane",
    "joined_at": "2021-03-15T15:49:01.384Z"
  },
  ...
]
```

Error (403):
```
{
  "type": "auth:unauthorized",
  "title": "Bad Request",
  "detail": "The request failed due to invalid credentials"
}
```
</details>

<details>
    <summary>Get Conversation Detail</summary>

This returns a conversation a user is a part of. A JWT is required in the request's header.

**Endpoint:** `/conversations/:conv_id`

**Method:** `GET`

**Headers:** 

`'Authorization: Bearer $JWT'`

**Response:**

Success (200):
```
{
  "state": "ACTIVE",
  "created_at": "2021-03-15T15:49:01.029Z",
  "id": "CON-dae195ea-e3c3-4560-9de7-cb30a4c0b6e1",
  "users": [
    {
      "id": "USR-43462453-b3be-4e01-9d3c-5f2525bc79d5",
      "name": "dwane",
      "display_name": "dwane",
      "state": "JOINED"
    },
    ...
  ],
  "name": "dwane",
  "joined_at": "2021-03-15T15:49:01.384Z",
  "events": [
    {
      "id": 2,
      "from": "USR-44326d04-cd82-41f5-ad24-315c2a2eac41",
      "type": "member:joined",
      "content": null,
      "timestamp": "2021-03-15T15:49:01.384Z"
    },
    ...
  ]
}
```

Error (403):
```
{
  "type": "auth:unauthorized",
  "title": "Bad Request",
  "detail": "The request failed due to invalid credentials"
}
```
</details>

<details>
    <summary>New Conversation</summary>

This creates a new conversation with the users supplied.

**Endpoint:** `/conversations`

**Method:** `POST`

**Headers:** 

`'Authorization: Bearer $JWT'`

`'Content-Type: application/json'`

**Response:**

Success (200):
```
{
  "state": "ACTIVE",
  "created_at": "2021-03-16T12:20:44.738Z",
  "id": "CON-258ce13c-1a93-47c5-b978-d8bb18c70c45",
  "users": [
    {
      "id": "USR-43462453-b3be-4e01-9d3c-5f2525bc79d5",
      "name": "dwane",
      "display_name": "dwane",
      "state": "JOINED"
    }
  ],
  "name": "dwane",
  "events": []
}
```

Error (403):
```
{
  "type": "auth:unauthorized",
  "title": "Bad Request",
  "detail": "The request failed due to invalid credentials"
}
```
</details>