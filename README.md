# "The V-app"

## About this project

This is "The V-app", a messaging multi-platform application that lets users chat via text, voice and video. The app will be built on top of the [Vonage Conversation APIs](https://developer.nexmo.com/conversation/overview) using the [Vonage Client SDKs](https://developer.nexmo.com/client-sdk/overview). The project requires an accompanying server to support the clients, view the [server guide](server.md) for more information and API specification.

## Installation Guide

To seamlessly download, setup and run all 3 clients and the backend, you can install the [scaffold plugin](https://developer.vonage.com/blog/22/08/25/introducing-the-vonage-client-sdk-v-app-demo-projects#the-vonage-cli-scaffold-plugin) for the Vonage CLI. To manually run the applications:

### Server

Change directory into `backend-node` and install dependencies:

```sh
cd backend-node
npm install
```

Create a new Vonage app:

```sh
vonage apps:create "v-app-test" --capabilities=voice,rtc --voice_answer_url=https://example.com/voice/answer --voice_event_url=https://example.com/voice/events --rtc_event_url=https://example.com/rtc/events
```

Create an `.env` file and add the app id and private key:

```sh
cp .env-sample .env
less vonage_app.json
```

Once you have deployed the backend, open your application on the [Vonage API dashboard](https://dashboard.nexmo.com) and update the webhook URLs.


### Web Client

Change Directory into client-web
`cd client-web`

Install dependencies
`npm install`

Replace JWTs and Conversation ID in the `index.html` with ones generated for your application.

Open `index.html` into a web bowser

Type either `Alice` or `Bob` into the input box and press the Login button.

### iOS Client

To use the iOS client you will need to use the terminal to install the dependencies and open the project.
Open your terminal, navigate to the `client-ios` folder and complete the following steps.

Install the dependencies with [Cocoapods](https://cocoapods.org):

`pod install`

Open the project workspace:

`open TheApp.xcworkspace`


### Android Client

1. Clone this repository
2. Run `Android Studio`, use to `File` -> `Open` menu and select `client-android` folder to open this project


## Contributing

Thank you for taking the time to contribute, feel free to ask questions.

We love to receive contributions from the community and hear your opinions! We want to make contributing to dial-a-carol as easily as it can be.

To get started:

•	Ensure you go through the [README.md](https://github.com/nexmo-community/clientsdk-the-v-app/blob/main/README.md) document so you can get familiar with the project.

•	Check the [Issues](https://github.com/nexmo-community/clientsdk-the-v-app/issues) for open tickets.

•	Create a pull request [here](https://github.com/nexmo-community/clientsdk-the-v-app/pulls). [See this page for a guide on making pull request](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).


## License
Distributed under **MIT** License. See [License](https://github.com/nexmo-community/clientsdk-the-v-app/blob/main/LICENSE) for more information.
