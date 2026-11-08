---
title: "Samila"
summary: Create generative art from random mathematical distributions

weight: 8
tags: ["Python", "FastAPI", "TypeScript", "Next.js", "Docker"]
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
  image: "/samila/samila-preview.webp"
  alt: "samila"
  caption: ""
  relative: false
  hidden: false
---

[samila.evanslack.dev](https://samila.evanslack.dev/)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/samila-ui)

## About

[Samila](https://github.com/sepandhaghighi/samila) is an open-source python library for creating generative art. It runs thousands of points through two random equations and plots the result. When I found it on Github I was mesmerized by the patterns it makes, and I submitted a few pull requests to add [new](https://github.com/sepandhaghighi/samila/pull/96) [functionality](https://github.com/sepandhaghighi/samila/pull/106) and [improve documentation](https://github.com/sepandhaghighi/samila/pull/92).

This project is a web app and HTTP API that makes samila usable from the browser, no python install needed. Pick one of 171 equation variations or let samila write random ones, then tune the projection, plot mode, grid, colors or gradient, marker shape, size and rotation. Every image is reproducible from its seed, and can be downloaded as a PNG up to 4000px.

![Samila Screenshot](/samila/samila-ui.webp)

## Design

```
  Browser ──> FastAPI ──┬── /api/*  ──> process pool ──> samila + matplotlib
                        └── /*  ──> Next.js static export
```

<br/><br/>

The backend is a [FastAPI](https://github.com/fastapi/fastapi) app that also serves the [Next.js](https://nextjs.org/) and [Mantine](https://mantine.dev/) frontend as a static export, so the whole application ships as one container.

Rendering an image with matplotlib can take a few seconds of CPU, so renders run in a process pool and never block the event loop. A small bounded queue sits in front of the pool. When it is full the API returns a 503 right away instead of piling up work, and renders that run too long return a 504. Requests are also rate limited per client and globally.

Images are deterministic, so a request that pins both the seed and the equations is cached as immutable. The seed and equations used are always returned in `X-Seed`, `X-F1` and `X-F2` headers, even when they were picked at random.

## API

Render an image:

```bash
curl -o art.png "https://samila.evanslack.dev/api/image?eq=7&seed=4242&proj=polar&color=ffffff&bg=000000&size=2000"
```

- `GET /api/image` renders a PNG, every parameter is optional
- `GET /api/config` returns a [samila config](https://github.com/sepandhaghighi/samila#config) for an image, to render it locally with `GenerativeImage(config=...)`
- `GET /api/equations` lists the equations and the pair behind each variation
- `GET /api/colormaps` lists the colormaps available for gradients

The editor can copy the API call or the samila config for any image. Full docs are at [/api/docs](https://samila.evanslack.dev/api/docs).

## Deploying

There are prebuilt docker images at `evanofslack/samila:latest`

```yaml
services:
  samila:
    image: evanofslack/samila:latest
    ports:
      - 8080:8080
```
