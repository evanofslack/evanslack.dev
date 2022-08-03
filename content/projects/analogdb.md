---
title: "AnalogDB"
summary: Public REST API serving thousands of film photographs

# weight: 1
# aliases: ["/first"]
tags: ["Golang", "Postgres", "Heroku", "Python", "Docker", "React"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "The collection of film photography"
showDescription: true
canonicalURL: "https://evanslack.dev/analogdb/"
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
    image: "" # image path/url
    alt: "Placeholder" # alt text
    caption: "Analog Picture" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---


### About

[AnalogDB](https://analogdb.com) provides a large collection of curated analog photographs to users through a REST API interface. Beyond just returning photos, AnalogDB provides methods for sorting by time or popularity, enables filtering by nsfw, black & white, and exposed sprockets, and allows for querying by film stock, camera model and camera settings. 

![AnalogDB Screenshot](/analogdb-screenshot.png)

### Design

AnalogDB makes use of several technologies and services to enable a full featured product. 

<!-- <img width="681" alt="Screen Shot 2022-07-19 at 8 50 39 PM" src="https://user-images.githubusercontent.com/51209817/179872652-32c019e3-2e3c-4086-84fe-b6e149522e2d.png"> -->
![AnalogDB Design](https://user-images.githubusercontent.com/51209817/179872652-32c019e3-2e3c-4086-84fe-b6e149522e2d.png#center)


Data is scraped from reddit and ingested with [analog-scraper](https://github.com/evanofslack/analog-scraper), a python service. In addition to scraping, this service is responsible for transforming raw images, uploading to [AWS S3](https://aws.amazon.com/s3/), and loading metadata into [Postgres](https://www.postgresql.org/). Images from S3 are served from [CloudFront CDN](https://aws.amazon.com/cloudfront/) for quick and reliable delievery. 

The core backend application is written in [Go](https://go.dev/) and makes use of [Chi](https://github.com/go-chi/chi) as an HTTP router. It exposes handlers that are responsible for filtering incoming requests, establishing connections with Postgres, and returning JSON responses. The Go application and Postgres database are containerized with [Docker](https://www.docker.com/) for reliable development and deployment. The backend is currently hosted on [Heroku](https://www.heroku.com/).   

The frontend web application is built with [Next.js](https://github.com/vercel/next.js/), making use of server-side rendering and incremental static regeneration for quick loading pages. [SWR](https://github.com/vercel/swr) is utilized for request caching and revalidation. All styles are built from scratch with [CSS Modules](https://github.com/css-modules/css-modules). The frontend is currently deployed with [Vercel](https://vercel.com/). 


### API

Full documentation for the API: https://analogdb.herokuapp.com/

### Example

```bash
curl https://analogdb.herokuapp.com/latest
```

```yaml
{
   meta:{
      total_posts:2420,
      page_size:10,
      next_page_id:1640889405,
      next_page_url:/latest?page_size=10&page_id=1640889405,
   },
   posts:[
      {
       id:2170,
       images:[
         {
           resolution: low,
           url: https://d3i73ktnzbi69i.cloudfront.net/3eae28ce-2294-437d-81df-87e86cff61c3.jpeg,
           width: 216,
           height: 320,
           },
           {
           resolution: medium,
           url: https://d3i73ktnzbi69i.cloudfront.net/400abc43-b8c5-44cf-a632-c1a849b14ab4.jpeg,
           width: 519,
           height: 768,
           },
           ...
         ],
         title: The San Remo from Central Park [Leica m6, Nokton 35mm f/1.4, Portra 400],
         author: u/_35mm_,
         permalink: https://www.reddit.com/r/analog/comments/u26upj/the_san_remo_from_central_park_leica_m6_nokton/,
         upvotes: 89,
         nsfw: false,
         unix_time: 1649790635,
         sprocket: false,
      },
      ...
   ]
}
```


[view the source code](https://github.com/evanofslack/analogdb)
