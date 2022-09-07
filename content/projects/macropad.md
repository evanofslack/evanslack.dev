---
title: "MacroPad"
summary: Custom PCB with embedded firmware powered by Raspberry Pi Pico

# weight: 1
# aliases: ["/first"]
tags: ["Pico", "CircuitPython", "PCB", "SolidWorks"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: false
canonicalURL: "https://evanslack.dev/macropad"
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
    caption: "" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---

[github](https://github.com/evanofslack/macropad)

## About

A wise professor once told me "Why buy something when you can build it for twice the price?". In this case, I wanted a small set of switches to control custom inputs on my computer. While there are many macro boards available for purchase, it is much cooler to design and build one from the ground up.

![GoPoker Screenshot](/macropad.gif)

## Hardware

I used KiCAD to design a PCB capable of supporting 6 switches, a rotary encoder, and 3 LEDs. The board implements a switch matrix with diodes and pull up resistors to route 6 switches to 5 pins. While a matrix isn't necessary for such a small design (the Pico has enough GPIO pins for each switch to get their own pin), I decided to implement it anyways as a learning exercise, as larger keyboards require matrices. 

This design utilized a Raspberry Pi Pico as the microcontroller. This inexpensive ($4) micro is the perfect choice for this build, as it can act as a Human Interface Device (HID)



