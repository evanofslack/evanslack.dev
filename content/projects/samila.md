---
title: "Samila"
summary: Create generative art from random mathematical distributions

weight: 3
# aliases: ["/first"]
tags: ["python", "typescript", "react"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: true
canonicalURL: "https://evanslack.dev/samila"
disableShare: true
disableHLJS: false
searchHidden: false
ShowReadingTime: false
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: false
ShowRssButtonInSectionTermList: false
ShowCodeCopyButtons: false
UseHugoToc: true
cover:
  image: "samila/samila-preview.png" # image path/url
  alt: "Placeholder" # alt text
  caption: "" # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
---

[samila-ui.vercel.app](https://samila-ui.vercel.app)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/samila-ui)

## About

[Samila](https://github.com/sepandhaghighi/samila) is an open-source python library that enables users to create generative art. When I discovered this library on Github, I was immediately mesmerized by the geometric patterns it can create. After reviewing the codebase and reading over the open issues, I submitted a few pull requests to add [new](https://github.com/sepandhaghighi/samila/pull/96) [functionality](https://github.com/sepandhaghighi/samila/pull/106) and [improve documentation](https://github.com/sepandhaghighi/samila/pull/92).

After playing around with the functionality in a few Jupyter Notebooks, I set out to create a web application that would allow users to create images from their browser without ever having to download and install the library.

## SamilaUI

[SamilaUI](https://samila-ui.vercel.app) is the result of an interactive React frontend and FastAPI backend that exposes Samila's functionality directly in the browser.

![Samila-ui Screenshot](/samila/samilaui-ss.png)

The [backend](https://github.com/evanofslack/samila-api) is a simple FastAPI application with one [main endpoint](https://samila-api.herokuapp.com/docs#/image/generative_image_image_get) that accepts a variety of query parameters. Each of the query parameters corresponds to an input to Samila's generator API for customizing the image. The endpoint returns a streamed buffer constituting the generated image.

The [frontend](https://github.com/evanofslack/samila-ui) is a Next.js application utilizing typescript and custom hooks to allow the user to easily customize the generator equation, projection, primary and background colors, spot size, and seed. In addition to generating images, users can also easily download their creations.

