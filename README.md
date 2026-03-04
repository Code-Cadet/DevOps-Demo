# DevOps Demo Project

A comprehensive DevOps demonstration project showcasing modern CI/CD practices, containerization, orchestration, and infrastructure as code.

## 🚀 Features

- **Express.js Backend API** with health checks and readiness probes
- **Multi-stage Docker builds** using distroless images for security
- **Kubernetes manifests** with auto-scaling and pod disruption budgets
- **GitHub Actions CI/CD** with automated testing, security scanning, and deployment
- **Infrastructure as Code** using Terraform for AWS
- **Security-first approach** with Trivy scanning and non-root containers

## 📋 Prerequisites

- **Node.js 22+** - For local development
- **Docker** - For containerization
- **kubectl** - For Kubernetes deployment
- **Terraform** - For infrastructure provisioning
- **Git** - For version control

## 🏃 Quick Start

### Option 1: Local Development

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Run the application
npm start

# Test the API
curl http://localhost:3000/healthz
```

### Option 2: Docker Compose (Recommended for Testing)

```bash
# Build and run with Docker Compose
docker-compose up -d

# Check logs
docker-compose logs -f

# Test the API
curl http://localhost:3000/healthz

# Stop the application
docker-compose down
```

### Option 3: Docker Standalone

```bash
# Build the Docker image
cd backend
docker build -t devops-demo-backend:latest .

# Run the container
docker run -d \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_PASSWORD=secure_password \
  --name backend \
  devops-demo-backend:latest

# Check container health
docker ps
docker logs backend

# Test the API
curl http://localhost:3000/healthz
curl http://localhost:3000/api/status
```

## 🧪 Testing

```bash
cd backend

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm test -- --coverage
```

## 🔐 Security

### Environment Variables

Create a `.env` file from the example:

```bash
cp .env.example .env
# Edit .env with your secure values
```

### Security Scanning

The project includes automated security scanning with Trivy:

```bash
# Scan Docker image locally
docker build -t devops-demo-backend:latest ./backend
trivy image devops-demo-backend:latest
```

## ☸️ Kubernetes Deployment

### Prerequisites

- A running Kubernetes cluster (minikube, kind, EKS, GKE, AKS)
- kubectl configured to access your cluster

### Deployment Steps

1. **Create the namespace (optional)**
   ```bash
   kubectl create namespace devops-demo
   kubectl config set-context --current --namespace=devops-demo
   ```

2. **Update secrets with your password**
   ```bash
   # Encode your password to base64
   echo -n "your_secure_password" | base64

   # Update infra/secrets.yaml with the encoded password
   ```

3. **Apply Kubernetes manifests**
   ```bash
   kubectl apply -f infra/secrets.yaml
   kubectl apply -f infra/deployment.yaml
   kubectl apply -f infra/service.yaml
   kubectl apply -f infra/hpa.yaml
   ```

4. **Verify deployment**
   ```bash
   # Check pods
   kubectl get pods -l app=backend

   # Check service
   kubectl get svc backend-service

   # View logs
   kubectl logs -l app=backend --tail=50 -f

   # Check horizontal pod autoscaler
   kubectl get hpa
   ```

5. **Test the API**
   ```bash
   # Get the external IP (LoadBalancer)
   kubectl get svc backend-service

   # For minikube
   minikube service backend-service --url

   # Test the endpoint
   curl http://<EXTERNAL-IP>/healthz
   ```

### Update Deployment

To update the deployment with a new image:

```bash
# Update the image
kubectl set image deployment/backend-dev backend-api=ghcr.io/your-username/devops_demo:new-tag

# Check rollout status
kubectl rollout status deployment/backend-dev

# Rollback if needed
kubectl rollout undo deployment/backend-dev
```

## 🏗️ Infrastructure as Code (Terraform)

Deploy AWS infrastructure:

```bash
cd infra

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply

# View outputs
terraform output

# Destroy resources when done
terraform destroy
```

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow that:

1. **Test** - Runs unit tests on every push and PR
2. **Build** - Builds Docker image with multi-stage builds
3. **Scan** - Performs security scanning with Trivy
4. **Push** - Pushes images to GitHub Container Registry (ghcr.io)
5. **Deploy** - Deploys to Kubernetes on main branch

### Setup CI/CD

1. **Enable GitHub Actions** in your repository settings

2. **Update the image reference** in `.github/workflows/ci.yml`:
   ```yaml
   env:
     REGISTRY: ghcr.io
     IMAGE_NAME: ${{ github.repository }}
   ```

3. **Update Kubernetes deployment** in `infra/deployment.yaml`:
   ```yaml
   image: ghcr.io/your-username/devops_demo:latest
   ```

4. **Push to main branch** to trigger the pipeline

5. **View the workflow** in the Actions tab

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information and version |
| `/healthz` | GET | Health check (liveness probe) |
| `/ready` | GET | Readiness check |
| `/api/status` | GET | System status and uptime |

### Example Requests

```bash
# Get API information
curl http://localhost:3000/

# Health check
curl http://localhost:3000/healthz

# Readiness check
curl http://localhost:3000/ready

# System status
curl http://localhost:3000/api/status
```

## 🛠️ Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make changes and test locally**
   ```bash
   npm install
   npm test
   npm start
   ```

3. **Test with Docker**
   ```bash
   docker-compose up --build
   ```

4. **Commit and push**
   ```bash
   git add .
   git commit -m "Add your feature"
   git push origin feature/your-feature
   ```

5. **Create a Pull Request** - CI will automatically run tests and security scans

6. **Merge to main** - Triggers deployment to production

## 🐛 Troubleshooting

### Port already in use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <process-id> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### Docker build fails
```bash
# Clear Docker cache
docker builder prune -af

# Rebuild
docker-compose build --no-cache
```

### Kubernetes pod not starting
```bash
# Describe the pod
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> --previous
```

### Connection refused to backend
```bash
# Check if pod is running
kubectl get pods

# Check if service has endpoints
kubectl get endpoints backend-service

# Port-forward for local testing
kubectl port-forward deployment/backend-dev 3000:3000
```

## 📈 Monitoring and Observability

### Health Checks

The application provides health endpoints for monitoring:

- **/healthz** - Liveness probe (is the app running?)
- **/ready** - Readiness probe (can the app accept traffic?)

### Kubernetes Metrics

```bash
# View pod resource usage
kubectl top pods

# View node resource usage
kubectl top nodes

# Check HPA status
kubectl get hpa backend-hpa
```

## 🗂️ Project Structure

```
.
├── backend/
│   ├── Dockerfile           # Multi-stage Docker build
│   ├── index.js            # Express.js application
│   ├── index.test.js       # Unit tests
│   ├── jest.config.js      # Jest configuration
│   └── package.json        # Node.js dependencies
├── infra/
│   ├── deployment.yaml     # Kubernetes deployment
│   ├── service.yaml        # Kubernetes service
│   ├── secrets.yaml        # Kubernetes secrets
│   ├── hpa.yaml            # Horizontal Pod Autoscaler
│   ├── main.tf             # Terraform main configuration
│   └── provider.tf         # Terraform provider config
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI/CD
├── docker-compose.yml      # Docker Compose configuration
└── README.md              # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is for demonstration purposes.

## 🆘 Support

For issues or questions, please open a GitHub issue.

---

