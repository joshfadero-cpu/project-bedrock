# Project Bedrock

Production-grade microservices platform on Amazon EKS.

AltSchool of Engineering, Tinyuka 2025, Third Semester Capstone.
Student ID: ALT/SOE/TIN/025/0206

## Status

In progress. Started 11 August 2026.

## What this builds

An EKS cluster in a purpose-built VPC, running the AWS Retail Store
Sample Application, backed by managed AWS data services rather than
in-cluster databases, with centralised logging, least-privilege
developer access, an event-driven serverless flow, and a CI/CD
pipeline that plans on pull request and applies on merge.

## Fixed constraints

| Resource | Value |
| --- | --- |
| AWS region | us-east-1 |
| EKS cluster | project-bedrock-cluster |
| VPC name tag | project-bedrock-vpc |
| Namespace | retail-app |
| Developer IAM user | bedrock-dev-view |
| Assets bucket | bedrock-assets-alt-soe-tin-025-0206 |
| Lambda function | bedrock-asset-processor |
| Tag on all resources | Project: tinyuka-2025-capstone |

## Repository layout

| Path | Contents |
| --- | --- |
| `terraform/` | Root configuration and six modules |
| `kubernetes/` | Namespace, Ingress and other raw manifests |
| `helm/` | Values overriding the retail app data layer |
| `lambda/` | Source for bedrock-asset-processor |
| `.github/workflows/` | Plan on pull request, apply on merge |
| `scripts/` | Bring-up, teardown and verification |
| `docs/` | Architecture diagram and notes |
| `evidence/` | Screenshots |

## Prerequisites

To be completed.

## Deployment guide

To be completed.

## Teardown guide

To be completed. Note that the Ingress must be deleted and its ALB
confirmed gone before terraform destroy, since the load balancer is
created by the AWS Load Balancer Controller and is not tracked in
Terraform state.
