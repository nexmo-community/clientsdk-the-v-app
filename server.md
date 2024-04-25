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

TODO: Add refresh and image endpoints

### Users

<details>
    <summary>Get Users</summary>

This returns a list of other users one can have a conversation with (excluding the requesting user). A JWT is required in the request's header. This is the JWT received from login/signup.


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

</details>
</br>