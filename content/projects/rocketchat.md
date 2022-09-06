
---
title: "Rocket.Chat SDK"
summary: Improving Rocket.Chat Golang SDK as part of Google Summer of Code

# weight: 1
# aliases: ["/first"]
tags: ["Golang", "SDK"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: true
canonicalURL: "https://evanslack.dev/rocketchat"
disableHLJS: true # to disable highlightjs
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
    image: "" # image path/url
    alt: "Placeholder" # alt text
    caption: "" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---
[github](https://github.com/RocketChat/Rocket.Chat.Go.SDK)

## About

Over the summer of 2022 I was given the opportunity to participate in Google Summer of Code, a project that Google organizes to give developers the chance to contribute to open-source at a deeper level. I worked alongside developers at Rocket.Chat, a company that creates a messaging platform similar to Slack or Microsoft Teams. During a 12 week period, I was responsible for improving their SDK, which allows users to make calls to the Rocket.Chat API natively in Go. 

## Contributions

#### Expanding Endpoint Coverage

The majority of my contributions were related to expanding the coverage of the SDK. When I started, only 24 endpoints were covered by the SDK. Over the period I was working on the project, I was directly responsible for increasing that to 33 endpoints covered (though at the time of writing not all code has been approved and merged). 

Most of my work involved using a wrapper around Go's `net/http` client to make HTTP calls to the rocket.chat backend. All work was completed following test driven development, so for every feature that was added, I ensured there were corresponding tests to confirm functionality. Testing was carried out using Go's `testing` library as well as the `assertify` library. 

One thing I found was critical create Go structs that correctly mirrored the backend's Typescript types. It was important to add annotations to the structs so that fields were properly marshalled to and from JSON and that fields were tagged with the the `omitempty` tag when necessary. 

In addition, I had to take care to consider how different errors should be handled throughout the SDK. There were a mix of potential errors that could arise; general HTTP errors, specific Rocket.Chat endpoint errors, and internal errors from potentially incorrect marshalling. It became important to consider how to wrap errors to provide correct context to end users of the SDK. 

#### Refactoring 

Beyond expanding coverage, I spent time collaborating with my mentors and other contributors to propose changes to improve existing parts of the codebase. The most signficant improvement that I implemented was to standardize the return types of various method calls across the SDK. Previously, the pattern was to return a `Response` stuct with embedded fields including the desired resource and a custom error type. The following example shows a method stub and corresponding response struct from the previous iteration. 

```golang
struct MessagesResponse{
    Messages []Messages
    Status ErrorStatus
}
```

```golang
func GetMessages(channel str) MessagesResponse {
    ...
}
```

I discussed the reasoning behind this implementation with my mentors and proposed changing the function signature to be more ideomatic Go, where errors are returned alongside resources. I then implemented the proposed changes across all methods, leading to the following function signature: 


```golang
func GetMessages(channel str) ([]Messages, error) {
    ...
}
```

The change is small but is important to be consistent with traditional Go patterns. One of the (subjectivly) greatest parts of the language is that it is verbose when it comes to error handling and most developers are accustomed to the pattern of checking a returned error for `nil` before proceeding. 


#### Containerizing the Development Environment

When I started working on the project, there were no instructions to help with setting up for local development. My first contribution was to expand the README to include details about how to build and test the source code locally. This included directions for configuring a docker-compose file responsible for spinning up the rocket.chat server and MongoDB instance for persistance. 

After working on the project for a while, I found myself making modifications to the rocket.chat server in the docker-compose stack, namely adding environemental variables to disable rate limiting on the backend which made testing much faster. I then worked with my mentor to submit a pull request incorpeating this docker-compose file into the repository along with improved instructions in the README to properly utilize this development environment. 

This contribution is important as it standardizes the environment in which all contributors run local tests. All new pull requests can be consistently tested, thus improving developer experience. 

## Takeaways

While I had made previous contributions to a variety of open-source projects, this was my first time investing this much time into one community. I improved my general coding skills and also learned some important lessons related to contributing to and maintaining larger open-source projects.

**Introducing breaking changes should not be taken lightly** - backwards compatibility is an important concept. Even though the SDK is not considered to be at a stable release and warns users that changes are to be expected, heavy consideration is needed before introducing breaking changes.

**Small and isolated pull requests are easier to manage** - I had a lot of sucess with creating feature branches off of main to implement smaller improvements and contributions. This lead to focused pull requests that are easier to review and merge. 

**Pace of code review in open-source** - sometimes maintainers have limited time to review pull requests. It is therefore important to communicate to ensure contributions are tackling the right problems.