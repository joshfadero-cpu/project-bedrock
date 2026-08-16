#!/usr/bin/env python3
"""
Project Bedrock architecture diagram.

Generates docs/architecture.png from code, so the diagram can be
regenerated whenever the platform changes rather than being redrawn
by hand.

Usage:
    pip install diagrams
    brew install graphviz          # or: apt-get install graphviz
    python3 docs/architecture.py
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, Lambda
from diagrams.aws.database import RDS, Dynamodb
from diagrams.aws.network import ELB, InternetGateway, NATGateway, VPC
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.aws.security import IAM, IAMRole
from diagrams.aws.devtools import Codepipeline
from diagrams.k8s.compute import Pod
from diagrams.onprem.client import Users
from diagrams.onprem.vcs import Github

GRAPH_ATTR = {
    "fontsize": "16",
    "labelloc": "t",
    "pad": "0.6",
    "nodesep": "0.6",
    "ranksep": "1.0",
    "bgcolor": "white",
}

with Diagram(
    "Project Bedrock  |  InnovateMart Retail Store on Amazon EKS  |  us-east-1",
    filename="architecture",
    outformat="png",
    show=False,
    direction="TB",
    graph_attr=GRAPH_ATTR,
):

    shopper = Users("Shopper\n(public internet)")
    developer = Users("bedrock-dev-view\n(read-only developer)")
    github = Github("GitHub Actions\nplan on PR, apply on merge")

    with Cluster("VPC  project-bedrock-vpc  10.0.0.0/16"):

        igw = InternetGateway("Internet Gateway")

        with Cluster("Public subnets  10.0.1.0/24, 10.0.2.0/24  (2 AZs)"):
            alb = ELB("Application\nLoad Balancer")
            nat = NATGateway("NAT Gateway\n(single, cost-conscious)")

        with Cluster("Private subnets  10.0.11.0/24, 10.0.12.0/24  (2 AZs)"):

            with Cluster("EKS  project-bedrock-cluster  (K8s 1.34)"):
                with Cluster("namespace  retail-app"):
                    ui = Pod("ui")
                    catalog = Pod("catalog")
                    carts = Pod("carts")
                    orders = Pod("orders")
                    checkout = Pod("checkout")
                    inclus = Pod("rabbitmq\nredis")

                eks = EKS("Managed node group\n2 x t3.medium, autoscaling to 4")

            with Cluster("Managed data layer"):
                mysql = RDS("RDS MySQL\ncatalog")
                postgres = RDS("RDS PostgreSQL\norders")

    dynamo = Dynamodb("DynamoDB\nbedrock-carts\n+ idx_global_customerId")
    assets = S3("S3  bedrock-assets-\nalt-soe-tin-025-0206")
    processor = Lambda("bedrock-asset-processor")
    logs = Cloudwatch("CloudWatch Logs\ncontrol plane + containers")
    irsa = IAMRole("IRSA role\ncarts to DynamoDB")

    # ---------------- User traffic ----------------
    shopper >> Edge(label="HTTP :80") >> alb
    alb >> Edge(label="Ingress\ntarget-type: ip") >> ui
    ui >> Edge(label="internal") >> [catalog, carts, orders, checkout]
    checkout >> Edge(style="dashed") >> inclus

    # ---------------- Data layer ----------------
    catalog >> Edge(label="3306") >> mysql
    orders >> Edge(label="5432") >> postgres
    carts >> Edge(label="IAM auth, no key") >> irsa >> dynamo

    # ---------------- Serverless flow ----------------
    developer >> Edge(label="s3:PutObject\n(scoped)", style="dashed") >> assets
    assets >> Edge(label="ObjectCreated:*") >> processor
    processor >> Edge(label='"Image received: file"') >> logs

    # ---------------- Egress and observability ----------------
    nat >> Edge(style="dashed", label="outbound only") >> igw
    eks >> Edge(style="dashed") >> logs

    # ---------------- Pipeline ----------------
    github >> Edge(label="OIDC, no stored keys", style="dotted") >> eks

    # ---------------- Developer read-only view ----------------
    developer >> Edge(label="EKS access entry\nview, retail-app only", style="dotted") >> eks
