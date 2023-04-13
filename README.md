# Nimbus
Self-hosted services in the Cloud.

## Introduction
Nimbus centralises Infrastructure (eg. Terraform deployments, Kubernetes Manifests & Docker Containers) that deploys self-hosted services on Cloud Platforms in one repository.

## Features
- **Economies of Scale**  Cross-cutting concerns between Self-hosted services (eg. Logging, Monitoring, CDN Caching & DNS) can be fulfilled via a set of shared services that only need to be deployed once.
- **Infrastructure as Code (IaC)** Expressing IaC makes infrastructure dynamic & malleable to changes. Dependencies between Multiple Cloud providers can be expressed explicitly in code. Checking IaC into Git provides checkpoints for rollbacks if something goes wrong.
- **Multi Cloud** Consolidates deployments on multiple Cloud Platforms (AWS, GCP, Cloudflare &amp; Blackblaze) in one place.

## Architecture
```mermaid
flowchart LR
    tls[Let's Encrypt TLS]
    b2[Blackblaze B2 Object Storage]

    subgraph cf[Cloudflare]
        direction TB
        DNS
        CDN
    end

    cf[Cloudflare] <--> gcp

    subgraph gcp[Google Cloud Platform]
        direction LR
        subgraph gae[App Engine]
            proxy[Nginx Proxy]
        end
        subgraph gce[Compute Engine]
            dev-env[WARP Dev Environment]
        end
        proxy <--> dev-env

        subgraph k8s[Kubernetes Engine]
            direction LR

            ingress[ingress-nginx] <--> oauth[OAuth2 Proxy]
            ingress <--> media & monitoring & pipeline & calibre-web[Calibre-Web]
            subgraph media[Media Namespace]
                torrent[Rtorrent & Flood UI] -->  media-svr[Jellyfin Server]
            end
            subgraph monitoring[Monitoring]
                log[Loki & Promtail]
                metrics[Prometheus]
                log & metrics --> dashboard[Grafana]
            end
            subgraph pipeline[Data Pipelines]
                airflow[Airflow]
            end
            subgraph analytics[Analytics]
                superset[Superset]
            end
        end
    end

    subgraph aws[Amazon Web Services]
        direction LR
        s3 -.-> glue[AWS Glue Crawler] -.-> redshift
        s3[(S3 Data Lake)] --> redshift[(Redshift Serverless)]
    end
```

## Services
User-facing services hosted on Nimbus:
- [WARP](https://github.com/mrzzy/warp): portable development environment based on Cloud VM
- [Jellyfin](https://jellyfin.org/): media server for personal media consumption.
- [Calibre-Web](https://github.com/janeczku/calibre-web): web eBook library for browsing & reading books.

## License
MIT.
