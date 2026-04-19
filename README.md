# AWS AI Platform Blueprint

A production-style AI platform blueprint on AWS using Kubernetes, GitOps, and modern platform engineering patterns.

This project is focused on designing, deploying, and operating AI-powered applications with an emphasis on:

- reliability over hype
- async processing over blocking workflows
- cost-aware architecture
- clean separation of concerns
- real-world platform constraints

## What This Is

This is not a toy chatbot.

It is a platform blueprint for AI workloads that supports:

- document ingestion pipelines
- embedding generation and vector search
- retrieval-augmented generation (RAG)
- scalable inference through managed or self-hosted models
- async job processing
- observability and cost visibility

## Current Repository Status

This repository is an early blueprint and scaffold.

Today, it includes:

- base Terraform for AWS networking and Amazon EKS
- bootstrap manifests for Argo CD
- starter GitOps and application directories
- simple deployment helper scripts

Several application and GitOps manifests are still placeholders. The sections below describe the intended platform architecture and target operating model.

## Architecture Overview

The platform is designed around two core flows.

### 1. Online Path (Low Latency)

```text
User -> Ingress -> API -> Retrieval -> Model -> Response
```

Characteristics:

- stateless services
- horizontally scalable components
- strict timeouts and retries
- optimized for latency-sensitive requests

### 2. Async Path (Durable Processing)

```text
Upload -> S3 -> Queue -> Workers -> Embeddings -> Vector Store
```

Characteristics:

- queue-backed processing with Amazon SQS
- idempotent workers
- retries and dead-letter queue handling
- optimized for durability over speed

## Core Components

### Application Services

- `API Service`: entry point for queries and uploads
- `Ingestion Worker`: parses and chunks documents
- `Embedding Worker`: generates embeddings
- `Retrieval Service`: performs vector similarity search
- `Inference Service`: calls the LLM through Amazon Bedrock or a self-hosted runtime
- `Orchestrator`: coordinates the end-to-end RAG workflow

### Platform Layer

- Amazon EKS
- Argo CD for GitOps
- Helm or Kustomize for packaging
- AWS Load Balancer Controller / ALB ingress
- External Secrets and IRSA
- Horizontal Pod Autoscaler
- optional KEDA for queue-based scaling

### AWS Infrastructure

- VPC with private subnets
- EKS cluster
- ECR for container images
- S3 for document and artifact storage
- SQS with DLQ for async processing
- RDS PostgreSQL with `pgvector` or Amazon OpenSearch for retrieval
- AWS Secrets Manager
- CloudWatch and OpenTelemetry
- AWS KMS for encryption

### Observability Stack

- Prometheus for metrics
- Grafana for dashboards
- Loki for logs
- OpenTelemetry for traces

## Model Strategy

The platform supports two operating modes.

### Managed (Recommended for MVP)

- Amazon Bedrock for LLM inference
- minimal operational overhead
- faster path to production

### Self-Hosted (Advanced)

- GPU-backed EKS nodes
- model serving with `vLLM`, `Triton`, or `TGI`
- autoscaling with Karpenter
- higher operational complexity with more control

## Deployment Model

### Infrastructure

Terraform defines AWS resources with environment-aware configuration and version-controlled changes.

### Applications

Argo CD continuously reconciles desired state from Git.

In practice:

- Git is the source of truth
- deployments are declarative
- rollback is a Git revert

## Scaling Strategy

| Component | Scaling Model |
| --- | --- |
| API / Retrieval | HPA based on CPU, memory, and latency signals |
| Workers | Queue-driven scaling with KEDA and SQS depth |
| Inference | Request-driven scaling |
| Storage | Managed AWS service scaling |

## Security Model

- IRSA for pod-level AWS access
- no static AWS credentials in containers
- AWS Secrets Manager integration
- private subnets with controlled egress
- encryption with AWS KMS
- least-privilege IAM policies

## Observability

The platform is intended to track:

- request latency (`p50`, `p95`, `p99`)
- error rates
- queue depth and lag
- worker throughput
- embedding failures
- model usage and cost
- system saturation signals

## Design Principles

- separate online and async workloads
- prefer managed services until complexity is justified
- optimize for failure isolation
- design for retryability and idempotency
- keep the platform boring, predictable, and observable
- avoid premature multi-region expansion and over-engineering

## Repository Structure

```text
.
├── terraform-aws-ai-platform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── s3/
│   │   ├── sqs/
│   │   ├── rds/
│   │   ├── iam-irsa/
│   │   └── observability/
│   └── live/
│       ├── dev/
│       └── prod/
│
├── ai-platform-gitops/
│   ├── clusters/
│   │   ├── dev/
│   │   └── prod/
│   ├── platform/
│   │   ├── ingress/
│   │   ├── observability/
│   │   ├── secrets/
│   │   └── autoscaling/
│   └── apps/
│       ├── api-service/
│       ├── ingestion-worker/
│       ├── embedding-worker/
│       ├── retrieval-service/
│       └── inference-service/
```

### Directory Notes

- `infra/`: Terraform for AWS infrastructure. The current implementation provisions a VPC and Amazon EKS cluster.
- `bootstrap/`: bootstrap Kubernetes manifests, including the initial Argo CD namespace and service account.
- `gitops/`: intended home for Argo CD applications and project definitions.
- `apps/`: starter Kubernetes application manifests.
- `scripts/`: helper scripts for deployment and cleanup workflows.

## Getting Started

### Prerequisites

- Terraform 1.x
- AWS CLI configured with appropriate credentials
- `kubectl`
- access to an AWS account

### Bootstrap Infrastructure

```bash
cd infra
terraform init
terraform apply
```

### Bootstrap Argo CD

Apply the bootstrap manifest to your cluster:

```bash
kubectl apply -f bootstrap/argo-install.yaml
```

### Helper Script

There is also a simple helper script:

```bash
./scripts/deploy.sh
```

Note: the repository is still a scaffold, so you will likely want to expand the Terraform variables, outputs, and GitOps manifests before using it as a full deployment stack.

## Roadmap

### Phase 1

- EKS and Argo CD bootstrap
- API and ingestion worker
- S3, SQS, and PostgreSQL with `pgvector`
- Amazon Bedrock inference
- basic observability

### Phase 2

- queue-based autoscaling with KEDA
- canary deployments
- improved RAG orchestration
- cost dashboards

### Phase 3

- self-hosted embedding service
- optional GPU-backed inference
- advanced observability with traces and evaluation workflows

## Why This Project Exists

Many AI demos ignore the hard parts of running systems in production.

This blueprint is meant to show a more realistic approach:

- durable pipelines instead of blocking everything on synchronous calls
- platform guardrails instead of ad hoc infrastructure
- operational visibility instead of blind inference requests
- pragmatic architecture decisions instead of hype-driven design
