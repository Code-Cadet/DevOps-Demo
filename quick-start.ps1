# DevOps Demo - Quick Start Script for Windows
# Run this script to quickly verify the backend is deployable

Write-Host "DevOps Demo - Quick Start" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "1. Checking prerequisites..." -ForegroundColor Yellow

$nodeExists = Get-Command node -ErrorAction SilentlyContinue
$dockerExists = Get-Command docker -ErrorAction SilentlyContinue

if (-not $nodeExists) {
    Write-Host "   [X] Node.js not found. Please install Node.js 22+" -ForegroundColor Red
    exit 1
}

$nodeVersion = node --version
Write-Host "   [✓] Node.js found: $nodeVersion" -ForegroundColor Green

if (-not $dockerExists) {
    Write-Host "   [!] Docker not found. Install Docker Desktop for full testing" -ForegroundColor Yellow
} else {
    Write-Host "   [✓] Docker found" -ForegroundColor Green
}

Write-Host ""

# Install dependencies
Write-Host "2. Installing dependencies..." -ForegroundColor Yellow
Set-Location backend
if (-not (Test-Path "node_modules")) {
    npm install
} else {
    Write-Host "   [✓] Dependencies already installed" -ForegroundColor Green
}

Write-Host ""

# Run tests
Write-Host "3. Running tests..." -ForegroundColor Yellow
$testResult = npm test
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [✓] All tests passed!" -ForegroundColor Green
} else {
    Write-Host "   [X] Tests failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Build Docker image (if Docker is available)
if ($dockerExists) {
    Write-Host "4. Building Docker image..." -ForegroundColor Yellow
    docker build -t devops-demo-backend:latest .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [✓] Docker image built successfully" -ForegroundColor Green
    } else {
        Write-Host "   [X] Docker build failed" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "5. Starting Docker container..." -ForegroundColor Yellow
    
    # Stop existing container if running
    docker stop devops-demo-backend 2>$null
    docker rm devops-demo-backend 2>$null
    
    # Start new container
    docker run -d `
        -p 3000:3000 `
        -e NODE_ENV=production `
        -e DATABASE_PASSWORD=demo_password_123 `
        --name devops-demo-backend `
        devops-demo-backend:latest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [✓] Container started successfully" -ForegroundColor Green
        
        # Wait for container to be ready
        Write-Host ""
        Write-Host "6. Waiting for application to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        
        # Test health endpoint
        try {
            $response = Invoke-WebRequest -Uri http://localhost:3000/healthz -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "   [✓] Application is healthy!" -ForegroundColor Green
                
                # Parse JSON response
                $healthData = $response.Content | ConvertFrom-Json
                Write-Host "   Status: $($healthData.status)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "   [X] Health check failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   [X] Failed to start container" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Deployment Successful!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend is running at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available endpoints:" -ForegroundColor Yellow
    Write-Host "  • http://localhost:3000/         - API info" -ForegroundColor White
    Write-Host "  • http://localhost:3000/healthz  - Health check" -ForegroundColor White
    Write-Host "  • http://localhost:3000/ready    - Readiness check" -ForegroundColor White
    Write-Host "  • http://localhost:3000/api/status - System status" -ForegroundColor White
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Yellow
    Write-Host "  • docker logs devops-demo-backend -f  - View logs" -ForegroundColor White
    Write-Host "  • docker stop devops-demo-backend     - Stop container" -ForegroundColor White
    Write-Host "  • docker-compose up                   - Use Docker Compose" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review README.md for full deployment options" -ForegroundColor White
    Write-Host "  2. Check DEPLOYMENT.md for Kubernetes deployment" -ForegroundColor White
    Write-Host "  3. Configure CI/CD in .github/workflows/ci.yml" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Docker not available. Install Docker Desktop to:" -ForegroundColor Yellow
    Write-Host "  • Build container images" -ForegroundColor White
    Write-Host "  • Test with Docker Compose" -ForegroundColor White
    Write-Host "  • Prepare for Kubernetes deployment" -ForegroundColor White
    Write-Host ""
    Write-Host "To run locally without Docker:" -ForegroundColor Yellow
    Write-Host "  npm start" -ForegroundColor White
}

Set-Location ..
