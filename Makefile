# DevOps Demo Makefile
# Simplifies common development and deployment tasks

.PHONY: help install test build run docker-build docker-run docker-stop k8s-deploy k8s-delete clean

# Default target
help:
	@echo "DevOps Demo - Available Commands:"
	@echo ""
	@echo "Local Development:"
	@echo "  make install        - Install backend dependencies"
	@echo "  make test          - Run tests"
	@echo "  make run           - Run backend locally"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run Docker container"
	@echo "  make docker-stop   - Stop and remove Docker container"
	@echo "  make compose-up    - Start with Docker Compose"
	@echo "  make compose-down  - Stop Docker Compose"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make k8s-deploy    - Deploy to Kubernetes"
	@echo "  make k8s-status    - Check Kubernetes status"
	@echo "  make k8s-logs      - View Kubernetes logs"
	@echo "  make k8s-delete    - Delete Kubernetes resources"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make tf-init       - Initialize Terraform"
	@echo "  make tf-plan       - Show Terraform plan"
	@echo "  make tf-apply      - Apply Terraform changes"
	@echo "  make tf-destroy    - Destroy Terraform resources"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make scan          - Run security scan"

# Local Development
install:
	cd backend && npm install

test:
	cd backend && npm test

run:
	cd backend && npm start

dev:
	cd backend && npm run dev

# Docker
docker-build:
	docker build -t devops-demo-backend:latest ./backend

docker-run:
	docker run -d \
		-p 3000:3000 \
		-e NODE_ENV=production \
		-e DATABASE_PASSWORD=demo_password \
		--name devops-demo-backend \
		devops-demo-backend:latest
	@echo "Backend running at http://localhost:3000"

docker-stop:
	docker stop devops-demo-backend || true
	docker rm devops-demo-backend || true

docker-logs:
	docker logs -f devops-demo-backend

compose-up:
	docker-compose up -d
	@echo "Services started. Backend at http://localhost:3000"

compose-down:
	docker-compose down

compose-logs:
	docker-compose logs -f

# Kubernetes
k8s-deploy:
	kubectl apply -f infra/secrets.yaml
	kubectl apply -f infra/deployment.yaml
	kubectl apply -f infra/service.yaml
	kubectl apply -f infra/hpa.yaml
	@echo "Waiting for deployment..."
	kubectl wait --for=condition=available --timeout=120s deployment/backend-dev

k8s-status:
	@echo "Pods:"
	kubectl get pods -l app=backend
	@echo "\nServices:"
	kubectl get svc backend-service
	@echo "\nHPA:"
	kubectl get hpa backend-hpa

k8s-logs:
	kubectl logs -l app=backend --tail=100 -f

k8s-delete:
	kubectl delete -f infra/hpa.yaml || true
	kubectl delete -f infra/service.yaml || true
	kubectl delete -f infra/deployment.yaml || true
	kubectl delete -f infra/secrets.yaml || true

k8s-port-forward:
	kubectl port-forward deployment/backend-dev 3000:3000

# Terraform
tf-init:
	cd infra && terraform init

tf-plan:
	cd infra && terraform plan

tf-apply:
	cd infra && terraform apply

tf-destroy:
	cd infra && terraform destroy

# Security
scan:
	docker build -t devops-demo-backend:scan ./backend
	trivy image devops-demo-backend:scan

# Cleanup
clean:
	cd backend && rm -rf node_modules coverage
	docker-compose down -v || true
	docker rmi devops-demo-backend:latest || true
	docker rmi devops-demo-backend:scan || true

# CI/CD simulation
ci-test:
	cd backend && npm ci && npm test

ci-build:
	docker build -t devops-demo-backend:ci ./backend

ci-scan:
	docker build -t devops-demo-backend:ci ./backend
	trivy image --exit-code 1 --severity CRITICAL,HIGH devops-demo-backend:ci

# Health check
health:
	@echo "Checking backend health..."
	@curl -f http://localhost:3000/healthz || echo "Backend not running"

# All in one
all: install test docker-build docker-run
	@echo "Application deployed locally"
