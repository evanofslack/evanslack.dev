---
title: "AnalogDB"
summary: Public REST API and web application exposing a collection of tens of thousands of film photographs

weight: 1
tags: ["Golang", "Postgres", "Weaviate", "Redis", "Kafka", "ClickHouse", "Python", "Dagster", "Next.js", "Docker"]
author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: true
comments: false
showDescription: false
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
  image: "/analogdb/analogdb-preview.webp" # image path/url
  alt: "analogdb" # alt text
  caption: "" # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: false # only hide on current single page
---

[analogdb.com](https://analogdb.com)
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
[github](https://github.com/evanofslack/analogdb)

## About

[AnalogDB](https://analogdb.com) provides a large collection of curated analog photographs to users through a REST API interface. Beyond just returning photos, AnalogDB tags each image with the camera and film it was shot on, writes a caption describing it, enables discovery of similar images, adds keyword labels, extracts dominant colors, and allows for filtering, sorting and searching by phrase across all images.

![AnalogDB Screenshot](/analogdb/analogdb-ss.webp)

## Design

AnalogDB makes use of several technologies and services to enable a full featured product.

![AnalogDB Design](/analogdb/analogdb-design.webp)

<br/><br/>

Data is scraped from reddit with [praw](https://github.com/praw-dev/praw) and ingested through a pipeline orchestrated by [Dagster](https://github.com/dagster-io/dagster). Along the way, an LLM reads each post title to pull out the camera, film and lens, a vision model writes a caption for each image, and keywords and dominant colors are extracted. This pipeline is also responsible for transforming raw images, uploading to [AWS S3](https://aws.amazon.com/s3/), and creation of resources through the backend api. Images from S3 are served from [CloudFront CDN](https://aws.amazon.com/cloudfront/) for quick and reliable delivery.

The core backend application is written in Go and makes use of [chi](https://github.com/go-chi/chi) as the HTTP router. It exposes versioned handlers under `/v1` that are responsible for parsing authentication headers, filtering incoming requests, querying databases, and returning JSON responses. Posts live in PostgreSQL, with [Redis](https://github.com/redis/redis) caching hot responses. Upon upload, all images are embedded with [CLIP](https://github.com/mlfoundations/open_clip) and stored in a [Weaviate](https://github.com/weaviate/weaviate) vector database, which powers both similarity search and searching photos by phrase. The backend is packaged as several docker containers and hosted on a VPS.

The frontend web application is built with [Next.js](https://github.com/vercel/next.js/) using the App Router, making use of server-side rendering for quick loading pages. Alongside the gallery there are pages for search and for browsing by film and camera. Components come from [Mantine](https://github.com/mantinedev/mantine) and styles are written with [CSS Modules](https://github.com/css-modules/css-modules).

The backend also publishes analytics events to [Kafka](https://github.com/apache/kafka), where a small Go consumer writes them into [ClickHouse](https://github.com/ClickHouse/ClickHouse). Everything is instrumented with OpenTelemetry and viewed through Grafana.

## API

Full documentation for the API: <https://api.analogdb.com/>

## Example

```bash
curl "https://api.analogdb.com/v1/posts?page_size=1"
```

```json
{
  "meta": {
    "total_posts": 38246,
    "page_size": 1,
    "next_cursor": "eyJzIjoidGltZSIsInYiOjE3OTQwMDM1MzUsImlkIjo1NTQ2OX0",
    "next_page_url": "/v1/posts?cursor=eyJzIjoidGltZSIsInYiOjE3OTQwMDM1MzUsImlkIjo1NTQ2OX0&page_size=1&sort=time"
  },
  "posts": [
    {
      "id": 55469,
      "title": "NYC - Halloween 2026 [ Nikon F2 | 28mm f/2.8 | Cinestill 800T ]",
      "author": "maxt21",
      "permalink": "https://www.reddit.com/r/analog/comments/1xppww4/nyc_halloween_2026_nikon_f2_28mm_f28_cinestill/",
      "description": "Had fun shooting Halloween this year in Brooklyn. Last year I did the same and it was a lot of fun. This year was also a lot of fun",
      "caption": "A man with yellow face paint and a small anchor decoration on his head smiles at the camera in a subway station.",
      "score": 108,
      "nsfw": false,
      "grayscale": false,
      "timestamp": 1794003535,
      "sprocket": false,
      "camera_make": "nikon",
      "camera_model": "f2",
      "film_make": "cinestill",
      "film_type": "800t",
      "film_speed": 800,
      "focal_length": 28,
      "aperture": "f/2.8",
      "images": [
        {
          "resolution": "low",
          "url": "https://i.analogdb.com/4044cdd36cc7e86d8065660c-low.jpeg",
          "width": 720,
          "height": 720
        },
        {
          "resolution": "medium",
          "url": "https://i.analogdb.com/4044cdd36cc7e86d8065660c-medium.jpeg",
          "width": 1080,
          "height": 1079
        }
      ],
      "colors": [
        {
          "hex": "#101111",
          "css": "black",
          "html": "black",
          "percent": 0.24719358
        },
        {
          "hex": "#2f2d33",
          "css": "darkslategray",
          "html": "black",
          "percent": 0.22062495
        }
      ],
      "keywords": [
        { "word": "man", "weight": 1 },
        { "word": "halloween", "weight": 0.9583 }
      ]
    }
  ]
}
```

The response has been truncated here, real posts come with four image sizes, five colors and more keywords.

## Deploying

There are prebuilt docker images on Docker Hub:

- `evanofslack/analogdb` for the backend API
- `evanofslack/analogdb-web` for the frontend
- `evanofslack/analogdb-dagster` for the scraping pipeline
- `evanofslack/analogdb-consumer` for the analytics consumer

Please see the `docker-compose.yaml` for each service ([backend](https://github.com/evanofslack/analogdb/blob/main/backend/docker-compose.yaml), [web](https://github.com/evanofslack/analogdb/blob/main/web/docker-compose.yaml), [scrape](https://github.com/evanofslack/analogdb/blob/main/scrape/docker-compose.yaml) and [consumer](https://github.com/evanofslack/analogdb/blob/main/consumer/docker-compose.yaml)) for an example deployment with necessary variables and services.
