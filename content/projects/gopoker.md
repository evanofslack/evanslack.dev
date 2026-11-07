---
title: "GoPoker"
summary: Real-time multiplayer poker application powered by websockets

weight: 2
tags: ["Golang", "Websockets", "Postgres", "React"]
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: true
comments: false
description: ""
showDescription: false
canonicalURL: "https://evanslack.dev/gopoker"
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
  image: "/gopoker/gopoker-preview.webp" # image path/url
  alt: "gopoker" # alt text
  caption: "" # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: false # only hide on current single page
---

[poker.evanslack.dev](https://poker.evanslack.dev/)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/go-poker)

## About

GoPoker is a real-time multiplayer poker game powered by websockets. Users can create tables to play games of poker with their friends, no accounts or downloads, just send a link. Tables seat up to 9 players and support Texas Hold'em, Omaha and 5 card Omaha, played no limit or pot limit with a full or short deck. Every buy-in and cash out is tracked in a ledger that works out who owes who at the end of the night, along with player stats, stack charts and a full hand history. Common home game rules are built in too: straddles, running it twice, bomb pots, double boards, 7-2 bounties and time banks.

&nbsp;

![GoPoker Screenshot](/gopoker/gopoker-ss.webp)

## Design

GoPoker is a single Go server that handles websocket connections with Gorilla Websockets and serves the frontend, a static export of a Next.js app built with React, Mantine and Tailwind. Table state is stored in Postgres, or SQLite for smaller setups. The backend is split into three layers. The poker engine holds plain game state with no locks or clocks, checks that every action is legal before applying it, and returns the events it caused. On top of that, each table is a reducer that takes the current state and a command and returns the new state, covering seats, host controls, the ledger, stats and bots. Finally the server runs each table as its own goroutine that owns its state and connections. Clients only ever receive a view built for them, so other players' hole cards never leave the server.

The first version of this project ran on Heroku and used Redis as a message broker, since Heroku could run multiple dynos and separate instances needed a way to share events for a single poker table. The rewrite dropped this in favor of giving each table a single owner. With one goroutine handling every action for a table, the game logic is much simpler to reason about and test, and a single server has plenty of room for a lot of home games.

The persistent datastore that was missing from the first version now exists. Since table state is plain JSON, it is saved to the database between hands and on shutdown. A graceful restart picks back up in the middle of a hand, while a crash rewinds to the end of the last hand and deals it again. Turns out it didn't even need jsonb, a text column in Postgres works fine :)

## Bots

Empty seats can be filled with bots, or you can practice against them on your own. There are three levels of bots. Easy is a calling station that checks when it can and calls most bets. Medium compares its equity, found with Monte Carlo simulation, against the pot odds. Hard reads each opponent's range from how they have played the hand and their public stats, weighting hands by every bet, call and check, then picks the move worth the most chips across a few bet sizes, with push or fold when short stacked. Hard plays every game the table can deal, and in simulated matches it beats medium in all of them, winning about 33 big blinds per 100 hands heads up in hold'em.
