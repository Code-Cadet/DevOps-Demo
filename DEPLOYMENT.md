# Deployment Guide

## Prerequisites Checklist

Before deploying, ensure you have:

- [ ] Docker installed and running
- [ ] kubectl configured for your cluster
- [ ] GitHub repository set up with Actions enabled
- [ ] Container registry access (ghcr.io)
- [ ] AWS credentials (for Terraform)

## Step-by-Step Deployment

### 1. Local Testing

```bash
# Install dependencies
cd backend
npm install

# Run tests
npm test

# Start locally
npm start

# Test endpoints
curl http://localhost:3000/healthz
```

### 2. Docker Testing

```bash
# Build image
docker build -t devops-demo-backend:latest ./backend

# Run container
docker run -d -p 3000:3000 \
  -e DATABASE_PASSWORD=test123 \
  devops-demo-backend:latest

# Test
curl http://localhost:3000/healthz
```

### 3. Set Up GitHub Actions

1. Go to your repository settings
2. Navigate to Settings → Actions → General
3. Enable "Read and write permissions" for GITHUB_TOKEN
4. Create any needed secrets in Settings → Secrets

### 4. Configure Container Registry

For GitHub Container Registry (ghcr.io):

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Build and tag
docker build -t ghcr.io/USERNAME/devops_demo:latest ./backend

# Push
docker push ghcr.io/USERNAME/devops_demo:latest
```

### 5. Kubernetes Deployment

#### A. Local Kubernetes (Minikube/Kind)

```bash
# Start minikube
minikube start

# Use local Docker daemon (minikube only)
eval $(minikube docker-env)

# Build image locally
docker build -t devops-demo-backend:latest ./backend

# Update deployment to use local image
# Edit infra/deployment.yaml:
# imagePullPolicy: Never

# Deploy
kubectl apply -f infra/secrets.yaml
kubectl apply -f infra/deployment.yaml
kubectl apply -f infra/service.yaml

# Access service
minikube service backend-service
```

#### B. Cloud Kubernetes (EKS/GKE/AKS)

```bash
# Configure kubectl for your cluster
# For EKS:
aws eks update-kubeconfig --name your-cluster --region us-east-1

# For GKE:
gcloud container clusters get-credentials your-cluster --zone us-central1-a

# For AKS:
az aks get-credentials --resource-group your-rg --name your-cluster

# Create namespace
kubectl create namespace production

# Set context
kubectl config set-context --current --namespace=production

# Update secrets with production values
echo -n "your_prod_password" | base64
# Update infra/secrets.yaml

# Deploy
kubectl apply -f infra/secrets.yaml
kubectl apply -f infra/deployment.yaml
kubectl apply -f infra/service.yaml
kubectl apply -f infra/hpa.yaml

# Wait for external IP
kubectl get svc backend-service -w

# Test
EXTERNAL_IP=$(kubectl get svc backend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP/healthz
```

### 6. AWS Infrastructure (Terraform)

```bash
cd infra

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Get outputs
terraform output
```

### 7. CI/CD Pipeline Setup

1. Update `.github/workflows/ci.yml` with your registry:
   ```yaml
   env:
     REGISTRY: ghcr.io
     IMAGE_NAME: your-username/devops_demo
   ```

2. Update `infra/deployment.yaml` with your image:
   ```yaml
   image: ghcr.io/your-username/devops_demo:latest
   ```

3. Push to main to trigger pipeline:
   ```bash
   git add .
   git commit -m "Configure CI/CD"
   git push origin main
   ```

4. Monitor in GitHub Actions tab

### 8. Verification

```bash
# Check pods
kubectl get pods -l app=backend

# Check service
kubectl get svc backend-service

# Check HPA
kubectl get hpa

# View logs
kubectl logs -l app=backend --tail=50

# Test endpoints
curl http://<EXTERNAL-IP>/healthz
curl http://<EXTERNAL-IP>/ready
curl http://<EXTERNAL-IP>/api/status
```

## Rollback Procedure

If deployment fails:

```bash
# Check rollout history
kubectl rollout history deployment/backend-dev

# Rollback to previous version
kubectl rollout undo deployment/backend-dev

# Rollback to specific revision
kubectl rollout undo deployment/backend-dev --to-revision=2

# Check status
kubectl rollout status deployment/backend-dev
```

## Scaling

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment/backend-dev --replicas=5

# Verify
kubectl get pods
```

### Auto Scaling

The HPA is already configured in `infra/hpa.yaml`:
- Min: 2 replicas
- Max: 10 replicas
- Target CPU: 70%
- Target Memory: 80%

```bash
# Check HPA status
kubectl get hpa backend-hpa

# Watch HPA in action
kubectl get hpa -w
```

## Monitoring

### View Logs

```bash
# All pods
kubectl logs -l app=backend --tail=100 -f

# Specific pod
kubectl logs <pod-name> -f

# Previous container (if crashed)
kubectl logs <pod-name> --previous
```

### Resource Usage

```bash
# Pod metrics
kubectl top pods

# Node metrics
kubectl top nodes
```

### Events

```bash
# Recent events
kubectl get events --sort-by='.lastTimestamp'

# Events for specific pod
kubectl describe pod <pod-name>
```

## Troubleshooting

### Pod not starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events
```

### Image pull errors

```bash
# Check if secret exists
kubectl get secrets

# Verify image exists
docker pull ghcr.io/your-username/devops_demo:latest

# Create image pull secret if needed
kubectl create secret docker-registry regcred \
  --docker-server=ghcr.io \
  --docker-username=your-username \
  --docker-password=your-token
```

### Service not accessible

```bash
# Check endpoints
kubectl get endpoints backend-service

# Port forward for testing
kubectl port-forward deployment/backend-dev 3000:3000

# Test locally
curl http://localhost:3000/healthz
```

## Production Checklist

Before going to production:

- [ ] Update all passwords and secrets
- [ ] Enable resource limits in deployment
- [ ] Configure monitoring and alerting
- [ ] Set up log aggregation
- [ ] Configure backup strategy
- [ ] Test rollback procedure
- [ ] Document runbook
- [ ] Set up DNS for LoadBalancer
- [ ] Enable TLS/SSL
- [ ] Configure network policies
- [ ] Set up RBAC properly
- [ ] Enable audit logging
- [ ] Test disaster recovery

## Cleanup

### Remove Kubernetes Resources

```bash
kubectl delete -f infra/hpa.yaml
kubectl delete -f infra/service.yaml
kubectl delete -f infra/deployment.yaml
kubectl delete -f infra/secrets.yaml
```

### Remove Terraform Resources

```bash
cd infra
terraform destroy
```

### Remove Docker Resources

```bash
docker-compose down -v
docker rmi devops-demo-backend:latest
```

## Next Steps

1. **Add monitoring**: Prometheus, Grafana
2. **Add logging**: ELK Stack or Loki
3. **Add tracing**: Jaeger or Zipkin
4. **Add service mesh**: Istio or Linkerd
5. **Add certificate management**: cert-manager
6. **Add ingress**: nginx-ingress or Traefik
7. **Add GitOps**: ArgoCD or Flux

---

For questions or issues, refer to the main README.md or create a GitHub issue.
