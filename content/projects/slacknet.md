---
title: "Slacknet"
summary: Homelab with kubernetes, virtual machines, containers and more

# weight: 1
# aliases: ["/first"]
tags: ["k3s", "docker", "homelab"]
# author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: false
comments: false
description: ""
showDescription: true
canonicalURL: "https://evanslack.dev/slacknet"
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
[github](https://github.com/evanofslack/slacknet)

## About

I manage a few physical machines and self-host many services in my homelab. What started as a single raspberry pi running a few docker containers has grown to multiple servers in a highly avaliable proxmox cluster running network storage, LXCs, and a k3s cluster. I also have a pair of raspberry pis running redundant DNS and adblock services.

## Hardware

I currently run 3 main servers in my lab: a host node with lots of memory for multiple master and worker VMs, a storage node with ZFS-backed network store, and a workstation with powerful CPU and GPU for compute intensive tasks. 

**Host Node**
- AMD Ryzen 5600X (6 cores, 12 threads)
- 128Gb DDR4 3200mHz RAM
- 1Tb NVME SSD
- Proxmox VME

*This server runs ~10 virtual machines, most of which are k3s nodes.*

**Storage Node**
- Intel core i5 10400 (6 cores, 12 threads) w/ quicksync iGPU
- 128Gb DDR4 3200mHz RAM
- 2Tb NVME SSD
- 2x 14Tb drives in ZFS mirror
- Proxmox VME

*This machine is primarily a NAS and fileserver, but also runs an LXC for my VPN (tailscale) as well as multiple docker containers for redundant services.*

**Workstation**
- Intel core i7 12700kf (8 cores, 16 threads)
- 32 Gb DDR4 3600mHz RAM
- Nvidia 3800 GPU (12Gb VRAM)
- 2Tb NVME SSD
- Windows 11 w/ WSL (Ubunutu) 

*This machine is my primary development station and also hosts services that require GPU compute.*

## k3s

My favorite part of the lab is my kubernetes cluster. As I am hosting on bare metal, I decided to go with k3s, a lightweight kubernetes implementation. The highly avaliable cluster runs across 9 virtual machines, with 3 master nodes, 3 worker nodes, and 3 storage nodes dedicated to longhorn storage. 

I have aimed to make setup and tear down of all infastructure as automated as possible. I have bash scripts to create Ubunutu CloudImage templates, use Terraform to provision the virtual machines on Proxmox, and then use Ansible playbooks to install k3s on the nodes. 

The entire cluster is managed declaritivly with Gitops, relying on Flux to sync all state between the cluster and github repository. This makes it incredibly easy redeploy the entire cluster when necessary and also track changes from a single source of truth. 

Most of the services I run are either Helm charts or collections of kustomize manifests. Here is a non-comprehensive and likely outdatted list of services and applications I run:

- Cloudnative Postgres Operator
- MongoDB Community Operator

In addition to open-source applications, I also use my cluster to deploy apps that I am activly developing. It has served as a great learning experience to understand how to write cloudnative applications with microservice patterns, distributed state, and liveliness and readiness probes. 