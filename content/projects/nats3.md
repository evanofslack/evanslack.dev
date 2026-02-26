---
title: "NATS3"
summary: Connect NATS Jetstream and S3 for long-term message storage and replay

weight: 4
tags: ["Rust", "NATS", "S3", "Postgres", "Docker", "Axum"]
author: "Evan Slack"
showToc: false
hideSummary: false
TocOpen: false
draft: false
hidemeta: true
comments: false
showDescription: false
canonicalURL: "https://evanslack.dev/nats3/"
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
  image: "/nats3/nats3-preview.png"
  alt: "nats3"
  caption: ""
  relative: false
  hidden: false
---

[github](https://github.com/evanofslack/nats-s3-connector)

## About

[NATS-S3-Connector](https://github.com/evanofslack/nats-s3-connector) bridges NATS Jetstream to S3 object storage, enabling long-term retention and replay of messages. The application provides bidirectional flow, storing messages from NATS to S3 and loading them back when needed. Through store and load jobs, messages are compressed into chunks, tracked with metadata, and made available for replay at any point in time.

![NATS-S3-Connector Screenshot](/nats3/nats3-ui.png)

## Design

NATS-S3-Connector operates on a two-tier storage model with Postgres serving as the metadata store and S3 providing long-term object storage for compressed message chunks.

```
    .----------.       .----------.       .----------.       .---------.
    |   NATS   |       | In-Memory|       | Compress |       |   S3    |
    | Jetstream+------>|  Buffer  +------>|  & Batch +------>|  Bucket |
    '----------'       '----------'       '----+-----'       '---------'
         |                  |                  |                   |
         |                  |                  |                   |
         |             Time elapsed or         v                   |
         |             threshold reached  .----------.             |
         |                                | Postgres |             |
         |                                |  Chunk   |             |
         |                                | Metadata |             |
         |                                '----------'             |
         |                                     ^                   |
         |                                     |                   |
         |                                     |                   |
         |                                     |                   |
    .----------.       .----------.       .----+----.       .---------.
    |   NATS   |       | Download |       | Postgres|       |   S3    |
    | Jetstream|<------+    &     |<------+  Query  |<------+  Bucket |
    '----------'       |Decompress|       | Chunks  |       '---------'
                       '----------'       '---------'
                           |
                           v
                      .----------.
                      |   Mark   |
                      | Deleted  |
                      '----------'

```

<br/><br/>

Store jobs consume messages from NATS subjects and buffer them in memory. When time elapses or the buffer reaches configured thresholds (max bytes or max messages), the batch is compressed and uploaded to S3. Chunk metadata including bucket location, time ranges, message counts, and content hashes are persisted to Postgres for tracking and retrieval.

Load jobs query Postgres for chunks matching specified streams, subjects, and time ranges. Chunks are downloaded from S3, decompressed, and messages are published back into NATS. After successful loading, chunks are be marked as deleted or removed entirely from the metadata store.

The application is built in Rust with [Axum](https://github.com/tokio-rs/axum) handling HTTP requests and [Tokio](https://github.com/tokio-rs/tokio) providing the async runtime. Connection pooling to Postgres is managed with [bb8](https://github.com/djc/bb8). The system exposes both an HTTP API and a CLI tool for managing jobs.

## CLI

A formatted CLI is provided for managing store and load jobs alongside the HTTP API.

Store jobs:

```bash
nats3 store list
```

```
╭──────────────────────────────────────┬───────────────────────┬─────────┬────────────────────────┬────────────┬──────────┬────────────╮
│ id                                   │ name                  │ status  │ bucket                 │ stream     │ consumer │ subject    │
╞══════════════════════════════════════╪═══════════════════════╪═════════╪════════════════════════╪════════════╪══════════╪════════════╡
│ 24ce1555-b937-4321-9fa2-5e853a833690 │ test-store-1772065940 │ Running │ test-bucket-1772065940 │ test-input │          │ test.input │
╰──────────────────────────────────────┴───────────────────────┴─────────┴────────────────────────┴────────────┴──────────┴────────────╯
```

Load jobs:

```bash
nats3 load list
```

```
╭──────────────────────────────────────┬─────────┬────────────────────────┬─────────────┬───────────────┬──────────────┬───────────────╮
│ id                                   │ status  │ bucket                 │ read stream │ read consumer │ read subject │ write subject │
╞══════════════════════════════════════╪═════════╪════════════════════════╪═════════════╪═══════════════╪══════════════╪═══════════════╡
│ 70c8b4d7-020a-475e-bcb8-9dcd6b4213b1 │ Success │ test-bucket-1772065893 │ test-input  │               │ test.input   │ test.output   │
╰──────────────────────────────────────┴─────────┴────────────────────────┴─────────────┴───────────────┴──────────────┴───────────────╯
```

Install with `cargo install --path cli`

## API

Store jobs consume messages from NATS and upload them to S3 as compressed chunks.

Create via HTTP:

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
            "name": "job-1",
            "stream": "jobs",
            "subject": "subject-1",
            "bucket": "bucket-1"
          }' \
  http://localhost:8080/store/job
```

Or with the CLI:

```bash
nats3 store create \
  --name job-1 \
  --stream jobs \
  --subject subject-1 \
  --bucket bucket-1
```

Load jobs download chunks from S3 and publish messages back into NATS.

Create via HTTP:

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
            "bucket": "bucket-1",
            "read_stream": "jobs",
            "read_subject": "subject-1",
            "write_subject": "destination"
          }' \
  http://localhost:8080/load/job
```

Or with the CLI:

```bash
nats3 load create \
  --bucket bucket-1 \
  --read-stream jobs \
  --read-subject subject-1 \
  --write-subject destination
```

## Metrics

Prometheus compatible metrics are exposed at `/metrics`. All metrics are prefixed with `nats3`.

```
# Job tracking
nats3_jobs_total{job_type="load",status="completed"} 1
nats3_jobs_current{job_type="store"} 1

# NATS throughput
nats3_nats_messages_total{direction="in"} 20
nats3_nats_messages_total{direction="out"} 20
nats3_nats_bytes_total{direction="in"} 20080
nats3_nats_bytes_total{direction="out"} 25868

# S3 operations
nats3_s3_objects_total{direction="out"} 3
nats3_s3_bytes_total{direction="in"} 25868
```

## Deploying

There are prebuilt docker images at `evanofslack/nats-s3-connector:latest`

```yaml
services:
  nats3:
    image: evanofslack/nats-s3-connector:latest
    ports:
      - 8080:8080
    volumes:
      - ./config.toml:/etc/nats3/config.toml
```

Build from source:

```bash
git clone https://github.com/evanofslack/nats-s3-connector
cd nats-s3-connector
cargo build
```

See the [examples](https://github.com/evanofslack/nats-s3-connector/tree/main/examples) directory for full deployment configurations.
