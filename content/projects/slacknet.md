---
title: "Slacknet"
summary: Homelab with kubernetes, virtual machines, containers and more

weight: 2
# aliases: ["/first"]
tags: ["kubernetes", "docker", "homelab", "proxmox"]
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
    image: "slacknet/slacknet-preview.png" # image path/url
    alt: "Slacknet" # alt text
    caption: "" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---

[github](https://github.com/evanofslack/slacknet)

## About

I manage a few physical machines and self-host many services in my homelab. What started as a single raspberry pi running a few docker containers has grown to multiple servers in a highly available proxmox cluster running Ceph, VMs, and a Talos K8s cluster. I also have a pair of raspberry pis running redundant DNS and adblock services.

![Slacknet Hardware](/slacknet/slacknet-hardware.png)

## Proxmox Cluster

I run a 3 node Proxmox cluster on Minisforum MS01s, providing virtualization and highly-available storage for my lab. Ceph runs on the Proxmox cluster, each node has 2 OSDs which are Samsung PM983 2TB enterprise SSDs. Each MS01 is connected with dual 10G NICs LAGG'd to my Unifi Pro Aggregation switch and dual 2.5G NICs LAGG'd to my Unifi Pro Max 24 port switch. I run seperate vlans for Proxmox corosync, VM public, Ceph public and Ceph private networks.

## Kubernetes Environment

On top of Proxmox, I run a Talos Kubernetes cluster managed declaratively with FluxCD.

The cluster runs several essential services:

- Cilium for pod networking and network policies
- MetalLB for load balancing, configured with BGP integration through Unifi Dream Machine Pro
- External DNS to automatically update DNS records for services
- External Secrets Operators connected to Hashicorp Vault to provide secrets
- NGINX as an ingress controller
- Ceph CSI for persistent storage, which connects to the underlying Ceph cluster

## TrueNAS Build

My NAS is built in a Supermicro CSE-836 chassis. It runs TrueNAS Core with a RAIDZ2 array of 14TB disks with 72TB useable. The system has 10G networking, which connects to the same aggregation switch as the Proxmox cluster. Its the target for VM backups, from Proxmox Backup Server.

## Raspberry Pi Infrastructure

I have a few Raspberry Pis handling specific tasks:

Two Pis run AdGuard Home in a redundant configuration with a virtual IP for active/standby failover. I also run homebridge and homeassistant, to connect my smarthome devices.

## Network Diagram

```
                       Internet
                          │
                          ▼
              Unifi Dream Machine Pro Router
                          │
                 ┌────────┴─────────┐
                 │                  │
                 ▼                  ▼
    Unifi Pro Aggregation      Unifi Pro Max 24 Port
       10G Switch                   Switch
         │                           │
         ├───► Proxmox Node 1 ◄─┐    ├───► Pi 1 (AdGuard + VIP)
         │                      │    │
         ├───► Proxmox Node 2 ◄─┼────┼────► Pi 2 (AdGuard Backup)
         │                      │    │
         ├───► Proxmox Node 3 ◄─┘    ├───► Workstation
         │                           │
         └───► TrueNAS               └───► Home Devices
```
