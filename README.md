# terraform-oci-arch-oke-autoscale-gitlab-runners

Deploy GitLab Runners on Oracle Container Engine for Kubernetes with autoscaling functionality to scale worker nodes automatically based on load for smooth running jobs in the CI/CD pipeline. This Terraform code will create an OKE cluster with all dependent resources (networking, worker node-pool), deploy cluster autoscalling and Gitlab runners. 




![](./images/git-lab-runner-kubernetes.png)


OKE cluster autoscaling is based on deployments resource booking. When booked resources exceed available resources (CPU, memory) on worker nodes, new worker nodes are added automatically to the cluster up to `max_number_of_nodes:10`. When cluster resources are not utilized, number of worker nodes will be decresed down to `min_number_of_nodes:3`.

Gitlab runners will handle pending CI/CD jobs and will book, by default, 0.2 CPU and 512M RAM. These values can be overriden using `KUBERNETES_CPU_REQUEST` and `KUBERNETES_MEMORY_REQUEST` variables. Default values can be modified in `locals.tf`.

## Prerequisites

1. OCI account with rights to:
    - manage dynamic groups
    - manage policies
    - manage network resources
    - manage OKE clusters
    - manage compute resources
    - manage resource manager service

  # Guapa Backend – Deployment & Infrastructure Guide

**Environment:** Oracle Cloud Infrastructure (OCI) + Kubernetes (OKE) + Terraform + Laravel

## 1. Overview

This document provides the full deployment workflow for the Guapa backend application:

- Infrastructure provisioning using Terraform
- Kubernetes (OKE) deployment
- Secrets and environment management
- OCI DevOps repository usage
- Database access configuration
- Troubleshooting essentials

Suitable for DevOps and backend engineers onboarding to the Guapa platform.

## 2. Terraform Deployment

### Initialize & validate
terraform init
terraform validate
terraform plan



### Apply changes
terraform apply



**Provisions:**
- OKE Cluster & Node pools
- VCN/Subnets
- MySQL DB System
- Load balancer resources
- IAM policies
- Required networking

## 3. Kubernetes Deployment Workflow

3.1 Create namespace
kubectl apply -f k8s/namespace.yaml

3.2 Create secrets
kubectl apply -f k8s/secrets.yaml

3.3 Deploy MySQL (if applicable)
kubectl apply -f k8s/mysql.yaml

3.4 Deploy application
kubectl apply -f k8s/deployment.yaml

3.5 Expose service
kubectl apply -f k8s/service.yaml

3.6 Apply HPA
kubectl apply -f k8s/hpa.yaml



## 4. Laravel ENV Secret Management

**.env file stored as `laravel-env` Kubernetes secret.**

### Update .env (Windows PowerShell)
$ns = "laravel-prod-ahm"
kubectl -n $ns delete secret laravel-env --ignore-not-found
kubectl -n $ns create secret generic laravel-env --from-file=.env="D:.env"



### Verify
kubectl -n laravel-prod-ahm get secret laravel-env -o yaml



## 5. OCI DevOps Repository

**Clone:**
SSH: ssh://devops.scmservice.me-riyadh-1.oci.oraclecloud.com/namespaces/ax45nhirzfe7/projects/laravelbackend/repositories/backend
HTTPS: https://devops.scmservice.me-riyadh-1.oci.oraclecloud.com/namespaces/ax45nhirzfe7/projects/laravelbackend/repositories/backend



**Basic Git:**
git clone <repo>
git pull
git add .
git commit -m "update"
git push



## 6. Check Secrets

MySQL
kubectl get secret mysql-secret -n laravel-prod-ahm -o yaml

Docker Registry (OCIR)
kubectl get secret ocirsecret -n laravel-prod-ahm -o yaml

Laravel
kubectl get secret laravel-env -n laravel-prod-ahm -o yaml



## 7. Troubleshooting

### 7.1 Pods
kubectl -n laravel-prod-ahm get pods -o wide



### 7.2 Logs
PHP-FPM
kubectl logs -n laravel-prod-ahm <pod> -c php-fpm --tail=200

Nginx
kubectl logs -n laravel-prod-ahm <pod> -c nginx --tail=200



### 7.3 Fix DB Credentials
Check current
kubectl -n laravel-prod-ahm get secret mysql-secret -o jsonpath="{.data.DB_HOST}" | %{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }

Update
kubectl -n laravel-prod-ahm delete secret mysql-secret
kubectl -n laravel-prod-ahm create secret generic mysql-secret
--from-literal=DB_HOST=10.20.30.90
--from-literal=DB_USERNAME=Admin
--from-literal=DB_PASSWORD="DBPasswordHERE"
--from-literal=DB_DATABASE=guapa_db

Restart
kubectl -n laravel-prod-ahm rollout restart deploy laravel-app



## 8. CI/CD Workflow

1. Developer pushes to OCI DevOps repo
2. Build pipeline creates `nginx-prod` & `fpm-prod` images
3. Images pushed to OCIR
4. `kubectl apply -f k8s/deployment.yaml`

## 9. Useful Commands

List secrets
kubectl -n laravel-prod-ahm get secrets

Edit deployment
kubectl -n laravel-prod-ahm edit deploy laravel-app

Port-forward
kubectl port-forward -n laravel-prod-ahm <pod> 8080:80

HPA
$ns="laravel-prod-ahm"
kubectl -n $ns get hpa
kubectl -n $ns describe hpa laravel-hpa



## 10. Architecture Diagram

            +-------------------------+
            |     OCI DevOps Repo     |
            +------------+------------+
                         |
                         v
            +-------------------------+
            |  OCI DevOps Build CI    |
            |  Build Docker Images    |
            +------------+------------+
                         |
                         v
             +------------------------+
             |       OCIR Registry    |
             +-------------+----------+
                           |
                           v
                +-------------------+
     +---------->     OKE Cluster    <-----------+
     |          | (Kubernetes Nodes) |           |
     |          +-------------------+           |
     |                    |                    |
     |          +---------+---------+          |
     |          |     Deployment     |         |
     |          | (nginx + php-fpm)  |         |
     |          +----+---------+----+         |
     |               |         |              |
     |        +------+    +----+----+         |
     |        | Pod 1 |  |  Pod 2  | <--------+
     |        +---+---+  +----+----+
     |            |           |
     |            v           v
     |        +--------------------+
     |        |   OCI MySQL DB     |
     |        +--------------------+
     |
     v

+-------------------+
| OCI LoadBalancer |
+---------+---------+
|
v
+---------+
| User |
+---------+



---

**This handbook serves as the official guide for Guapa backend infrastructure maintenance and deployment.**