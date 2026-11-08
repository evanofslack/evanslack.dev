---
title: "Pastebnn"
summary: Simple pastebin with expiring and burn on read pastes

weight: 5
tags: ["Rust", "Axum", "Svelte", "Redis", "Docker"]
author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: true
comments: false
showDescription: false
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
  image: "/pastebnn/pastebnn-preview.webp"
  alt: "pastebnn"
  caption: ""
  relative: false
  hidden: false
---

[bin.evanslack.dev](https://bin.evanslack.dev/)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/pastebnn)

## About

Pastebnn is a simple pastebin server built with Rust and Svelte. Pastes can be given a custom URL, set to expire after a period of time, or burned after they are read once.

![Pastebnn Screenshot](/pastebnn/pastebnn-ui.webp)

## Design

```
  Browser ──> Axum ──┬── /api/paste ──> Storer ──┬── In-Memory
                     │                           └── Redis
                     └── /*  ──> SvelteKit static build
```

<br/><br/>

Pastebnn runs as a single Rust binary built with [Axum](https://github.com/tokio-rs/axum) and [Tokio](https://github.com/tokio-rs/tokio). The same server handles the JSON API and serves the static [SvelteKit](https://svelte.dev/docs/kit) and [Tailwind](https://tailwindcss.com/) frontend, so the whole application ships as one container.

Storage sits behind a `Storer` trait with two implementations, chosen at startup. The in-memory store keeps pastes in a `HashMap` and a background task periodically clears out expired pastes. The Redis store writes with `SET NX EX`, where NX refuses to overwrite an existing key and EX lets Redis expire pastes natively.

Burn on read pastes should only ever be seen once, even if two people open the link at the same time. Only the reader whose `DEL` actually removes the key gets the paste back, everyone else gets a 404. Each paste also returns a delete token on creation, which is never shown again.

## API

Create a paste:

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"text": "hello world", "seconds_until_expire": 600}' \
  https://bin.evanslack.dev/api/paste
```

- `POST /api/paste` creates a paste and returns it with a `delete_token`
- `GET /api/paste/:key` returns a paste
- `DELETE /api/paste/:key` deletes a paste with the `X-Delete-Token` header

## Deploying

There are prebuilt docker images at `evanofslack/pastebnn:latest`

```yaml
services:
  pastebnn:
    image: evanofslack/pastebnn:latest
    ports:
      - 8080:8080
```

Pastes are kept in memory by default. To persist pastes with Redis, use the [docker-compose.yml](https://github.com/evanofslack/pastebnn/blob/main/docker-compose.yml) in the repo.
