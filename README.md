# Nimbus

Self-hosted services in the Cloud.

## Introduction

Nimbus centralises Infrastructure (eg. Terraform deployments, Docker Containers) that deploys self-hosted services on Cloud Platforms in one repository.

## Features

- **Infrastructure as Code (IaC)** Expressing IaC makes infrastructure dynamic & malleable to changes. Dependencies between Multiple Cloud providers can be expressed explicitly in code. Checking IaC into Git provides checkpoints for rollbacks if something goes wrong.
- **Multi Cloud** Consolidates deployments on multiple Cloud Platforms (Cloudflare &amp; Blackblaze) in one place.

## Architecture

```mermaid
flowchart LR
    subgraph cf[Cloudflare]
        direction TB
        DNS
        CDN
    end

    cf[Cloudflare] <--> art & site

    subgraph b2[Blackblaze B2]
        art[art.mrzzy.co site]
        lake[(Providence Data Lake)]
    end

    subgraph vercel[Vercel]
        site[mrzzy.co site]
    end
```

## Services

User-facing services hosted on Nimbus:

- [mrzzy.co](https://mrzzy.co): Coding Portfolio website hosted on Vercel.
- [art.mrzzy.co](https://art.mrzzy.co): Art website hosted on Blackblaze B2.

## License

MIT.
