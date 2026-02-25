---
title: "AnalogDB"
summary: Public REST API and web application exposing a collection of thousands of film photographs

weight: 1
# aliases: ["/first"]
tags: ["Golang", "Postgres", "Weaviate", "Python", "Docker", "React"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
# description: "The collection of film photography"
showDescription: true
canonicalURL: "https://evanslack.dev/analogdb/"
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
  image: "/analogdb/analogdb-preview.png" # image path/url
  alt: "analogdb" # alt text
  caption: "" # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
---

[analogdb.com](https://analogdb.com)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/analogdb)

## About

[AnalogDB](https://analogdb.com) provides a large collection of curated analog photographs to users through a REST API interface. Beyond just returning photos, AnalogDB enables discovery of similar images, adds keyword labels, extracts dominant colors, and allows for filtering, sorting and searching across all images.

![AnalogDB Screenshot](/analogdb/analogdb-ss-2.png)

## Design

AnalogDB makes use of several technologies and services to enable a full featured product.

![AnalogDB Design](/analogdb/analogdb-design.png)

<br/><br/>

Data is scraped from reddit and ingested with a python scraping service built on top of [praw](https://github.com/praw-dev/praw). In addition to scraping, this service is responsible for transforming raw images, extraction of keywords and colors, uploading to [AWS S3](https://aws.amazon.com/s3/), and creation of resources through the backend api. Images from S3 are served from [CloudFront CDN](https://aws.amazon.com/cloudfront/) for quick and reliable delievery.

The core backend application is written in Go and makes use of [chi](https://github.com/go-chi/chi) as the HTTP router. It exposes handlers that are responsible for parsing authentication headers, filtering incoming requests, querying databases, and returning JSON responses. Upon upload, all images are transformed with the [ResNet-50 CNN](https://datagen.tech/guides/computer-vision/resnet-50/) to create embeddings which are stored in a [Weaviate](https://github.com/weaviate/weaviate) vector database. The backend is packaged as several docker containers and hosted on a VPS.

The frontend web application is built with [Next.js](https://github.com/vercel/next.js/), making use of server-side rendering and incremental static regeneration for quick loading pages. [Zustand](https://github.com/pmndrs/zustand) is utilized for state management. All styles are built from scratch with [CSS Modules](https://github.com/css-modules/css-modules).

## API

Full documentation for the API: <https://api.analogdb.com/>

## Example

```bash
curl https://api.analogdb.com/posts
```

```yaml
{
   meta:{
      total_posts:5842,
      page_size:20,
      next_page_id:1684684780,
      next_page_url:"/posts?sort=latest&page_size=20&page_id=1684684780",
   },
   posts: [
      {
       id:7378,
       title: A Forest on the Coast | Portra 400 | Canon 1V | 50mm,
       author: navazuals,
       permalink: https://www.reddit.com/r/analog/comments/13p9lme/a_forest_on_the_coast_portra_400_canon_1v_50mm/,
       upvotes: 89,
       unix_time: 1684804283,
       nsfw: false,
       sprocket: false,
       images: [
       {
         resolution: low,
         url: https://d3i73ktnzbi69i.cloudfront.net/505e03d0-e6c2-4596-97d2-77d6831e802c.jpeg,
         width: 477,
         weight: 720,
       },
       {
         resolution: medium,
         url: https://d3i73ktnzbi69i.cloudfront.net/0149e7c5-cefe-4cfa-a731-c7696c067d98.jpeg,
         width: 716,
         height: 1080,
       },
       ...
       ],
       colors: [
       {
         hex: #5d5933
         css: darkolivegreen
         percent: 0.33687689
       },
       {
         hex: #c6c5b1
         css: silver
         percent: 0.24639529
       },
       ],
       ...
       keywords: [
       {
         word: portra
         weight: 0.2
       },
       {
         word: forest
         weight: 0.2
       },
       ...
      ],
    },
    ...
  ]
}
```

## Deploying

There are prebuilt docker images at `evanofslack/analogdb:latest`

Please see [docker-compose.yaml](https://github.com/evanofslack/analogdb/blob/main/docker-compose.yml) for an example compose deployment with necessary variables and services.
