---
title: "GoPoker"
summary: Real-time multiplayer poker application powered by websockets and messaging queues

weight: 2
# aliases: ["/first"]
tags: ["Golang", "Redis", "Websockets", "Heroku", "React"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: false
canonicalURL: "https://evanslack.dev/gopoker"
disableHLJS: true # to disable highlightjs
disableShare: true
disableHLJS: false
searchHidden: false
ShowReadingTime: false
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: false
ShowRssButtonInSectionTermList: false
UseHugoToc: true
cover:
    image: "gopoker/gopoker-preview.png" # image path/url
    alt: "Placeholder" # alt text
    caption: "" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---

[go-poker.vercel.app](https://go-poker.vercel.app)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/go-poker)

## About

GoPoker is a real-time multiplayer Texas Hold'em game powered by websockets. Users can create tables to play games of poker with their friends. The application currently supports multiple simultaneous games with up to 6 players, live chat capability, and full playback log. 


&nbsp;

![GoPoker Screenshot](/gopoker/gopoker-ss.png)

## Design

There are 3 main components that make up the GoPoker application, the frontend client, the backend server and the underlying Redis broker. The frontend UI is built with React and utilizes the Context API for storing game state as well as the useReducer hook for updating game state. The backend server is written in Go and uses Gorilla Websockets for handling live communication with clients. The server is responsible for listening for events from the clients, publishing them to the appropriate Redis channel, as well as communicating back to clients when responding to events on subscribed channels. In addition, all poker logic is securely handled on the backend with a fast Texas Hold'em engine.

One distinct challenge that this project presented was handling horizontal scaling in production. During initial development where everything ran on a local computer, all websocket events were handled by a single backend instance. When deploying to Heroku, it became evident that depending on the backend to handle events would not work. Heroku can use multiple dynos to serve the application, so it was possible that seperate instances would handle a single poker table. Without a shared queue, these instances would have no way to interact. Redis was then introduced as a way to communicate between server instances. 

Something that is lacking in the current iteration of this project is a persistant datastore. Currently, if the backend server goes down and is has to be recreated, there is no way to recover the state of the previously running games. In the future it would be beneficial to implement a database to store this information. This could potentially be a good usecase for a NoSQL database such as MongoDB or DynamoDB, due to the poker game state already existing in a nested JSON-like structure. 
