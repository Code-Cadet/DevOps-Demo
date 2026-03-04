# 🚀 Quick Start: Prometheus & Grafana Setup

## ✅ What Was Implemented

### 1. Backend Metrics (Express + prom-client)
- ✅ Prometheus client library added (`prom-client`)
- ✅ Default system metrics (CPU, memory, event loop, GC)
- ✅ Custom HTTP metrics (request duration, count, active connections)
- ✅ Metrics middleware for automatic tracking
- ✅ `/metrics` endpoint for Prometheus scraping

### 2. Prometheus Configuration
- ✅ `prometheus.yml` configuration file
- ✅ Backend scraping configured (every 10s)
- ✅ Docker container setup

### 3. Grafana Setup
- ✅ Grafana OSS container
- ✅ Persistent volumes for data
- ✅ Default admin credentials configured

### 4. Docker Compose
- ✅ All services orchestrated
- ✅ Shared network for service discovery
- ✅ Health checks configured
- ✅ Automatic restart policies

### 5. Tests
- ✅ Tests for `/metrics` endpoint
- ✅ Verification of metric content

## 🎯 Access Your Monitoring Stack

| Service | URL | Credentials |
|---------|-----|-------------|
| **Backend API** | http://localhost:3000 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3001 | admin / admin |

## 📊 Quick Commands

### Start Everything
```bash
docker-compose up -d
```

### Check Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f backend
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### Stop Everything
```bash
docker-compose down
```

### Test Metrics Endpoint
```bash
curl http://localhost:3000/metrics
```

## 🎨 Setting Up Your First Dashboard in Grafana

1. **Login to Grafana**
   - Open http://localhost:3001
   - Username: `admin`
   - Password: `admin`

2. **Add Prometheus Data Source**
   - Go to ⚙️ Configuration → Data Sources
   - Click "Add data source"
   - Select "Prometheus"
   - URL: `http://prometheus:9090`
   - Click "Save & Test"

3. **Create Dashboard**
   - Click + → Dashboard → Add new panel
   - Query: `rate(devops_demo_http_requests_total[1m])`
   - Panel title: "Request Rate per Second"
   - Click "Apply"

4. **Add More Panels** (Recommended)
   - **Memory Usage**: `devops_demo_process_resident_memory_bytes / 1024 / 1024`
   - **Response Time (P95)**: `histogram_quantile(0.95, rate(devops_demo_http_request_duration_seconds_bucket[5m]))`
   - **Active Connections**: `devops_demo_active_connections`
   - **CPU Usage**: `rate(devops_demo_process_cpu_user_seconds_total[1m]) * 100`

## 📈 Available Metrics

### System Metrics (Default)
- `devops_demo_process_cpu_user_seconds_total` - CPU usage
- `devops_demo_process_resident_memory_bytes` - Memory usage
- `devops_demo_nodejs_eventloop_lag_seconds` - Event loop lag
- `devops_demo_nodejs_heap_size_total_bytes` - Heap size
- `devops_demo_nodejs_heap_size_used_bytes` - Heap usage

### Custom Application Metrics
- `devops_demo_http_request_duration_seconds` - Request duration histogram
- `devops_demo_http_requests_total` - Total request counter
- `devops_demo_active_connections` - Active connections gauge

## 🧪 Generate Test Traffic

```bash
# Single request
curl http://localhost:3000/healthz

# Multiple requests (Git Bash or WSL)
for i in {1..100}; do curl http://localhost:3000/healthz; done

# PowerShell version
1..100 | ForEach-Object { Invoke-WebRequest -Uri http://localhost:3000/healthz -UseBasicParsing }
```

## 🔍 Useful PromQL Queries

Copy these into Prometheus (http://localhost:9090) or Grafana:

```promql
# Request rate per second
rate(devops_demo_http_requests_total[1m])

# Average response time
rate(devops_demo_http_request_duration_seconds_sum[5m]) / rate(devops_demo_http_request_duration_seconds_count[5m])

# 95th percentile response time
histogram_quantile(0.95, rate(devops_demo_http_request_duration_seconds_bucket[5m]))

# Requests by endpoint
sum by(route) (rate(devops_demo_http_requests_total[5m]))

# Error rate (5xx responses)
rate(devops_demo_http_requests_total{status_code=~"5.."}[1m])

# Memory usage in MB
devops_demo_process_resident_memory_bytes / 1024 / 1024

# CPU usage percentage
rate(devops_demo_process_cpu_user_seconds_total[1m]) * 100
```

## 📚 Next Steps

1. **Learn PromQL** - [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
2. **Build Dashboards** - Create custom visualizations in Grafana
3. **Set Up Alerts** - Configure alerting rules in Prometheus
4. **Explore Metrics** - Discover what metrics are most valuable for your application

## 🎓 More Information

For detailed documentation, see [MONITORING.md](MONITORING.md)

---

**Happy Monitoring! 📊✨**
