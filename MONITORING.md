# 📊 Monitoring & Observability Guide

This guide explains how to use Prometheus and Grafana for monitoring the DevOps Demo application.

## 🎯 Overview

The monitoring stack includes:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **prom-client**: Node.js client for Prometheus metrics

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Start the Monitoring Stack

```bash
# From the project root
docker-compose up -d
```

This will start:
- Backend API on `http://localhost:3000`
- Prometheus on `http://localhost:9090`
- Grafana on `http://localhost:3001`

### 3. Access the Services

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Backend API | http://localhost:3000 | N/A |
| Prometheus | http://localhost:9090 | N/A |
| Grafana | http://localhost:3001 | admin / admin |

## 📈 Available Metrics

### Default Metrics (System)
These metrics are automatically collected:

- `devops_demo_process_cpu_user_seconds_total` - CPU usage
- `devops_demo_process_resident_memory_bytes` - Memory usage
- `devops_demo_nodejs_eventloop_lag_seconds` - Event loop lag
- `devops_demo_nodejs_heap_size_total_bytes` - Heap size
- `devops_demo_nodejs_heap_size_used_bytes` - Heap usage
- `devops_demo_nodejs_gc_duration_seconds` - Garbage collection

### Custom Application Metrics

#### HTTP Request Duration (Histogram)
```
devops_demo_http_request_duration_seconds
```
Tracks the duration of HTTP requests with labels:
- `method` - HTTP method (GET, POST, etc.)
- `route` - Request route
- `status_code` - HTTP status code

#### HTTP Request Counter
```
devops_demo_http_requests_total
```
Total number of HTTP requests with the same labels as above.

#### Active Connections (Gauge)
```
devops_demo_active_connections
```
Current number of active connections to the API.

## 🔍 Using Prometheus

### 1. Verify Metrics Collection

1. Open Prometheus: http://localhost:9090
2. Go to **Status → Targets**
3. Verify `devops-demo-backend` is **UP**

### 2. Query Metrics

Go to the **Graph** tab and try these queries:

**Total Requests**
```promql
devops_demo_http_requests_total
```

**Request Rate (per second)**
```promql
rate(devops_demo_http_requests_total[1m])
```

**95th Percentile Response Time**
```promql
histogram_quantile(0.95, rate(devops_demo_http_request_duration_seconds_bucket[5m]))
```

**Memory Usage**
```promql
devops_demo_process_resident_memory_bytes / 1024 / 1024
```

**Error Rate**
```promql
rate(devops_demo_http_requests_total{status_code=~"5.."}[1m])
```

## 📊 Setting Up Grafana

### 1. Login to Grafana

1. Open http://localhost:3001
2. Login with `admin` / `admin`
3. (Optional) Skip password change for development

### 2. Add Prometheus as Data Source

1. Click **⚙️ Configuration → Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Configure:
   - **Name**: Prometheus
   - **URL**: `http://prometheus:9090`
   - **Access**: Server (default)
5. Click **Save & Test**

### 3. Create Your First Dashboard

#### Option A: Manual Dashboard

1. Click **+ → Dashboard**
2. Click **Add new panel**
3. In the query editor:
   - Select **Prometheus** as data source
   - Enter query: `rate(devops_demo_http_requests_total[1m])`
4. Configure:
   - **Panel title**: Request Rate
   - **Legend**: `{{method}} {{route}} ({{status_code}})`
5. Click **Apply**

#### Option B: Import Pre-built Dashboard

1. Click **+ → Import**
2. Enter Dashboard ID: `1860` (Node Exporter Full)
3. Select **Prometheus** as data source
4. Click **Import**

### 4. Sample Dashboard Panels

Here are some useful panels to add:

**Request Rate by Endpoint**
```promql
sum by(route) (rate(devops_demo_http_requests_total[5m]))
```

**Average Response Time**
```promql
rate(devops_demo_http_request_duration_seconds_sum[5m]) / rate(devops_demo_http_request_duration_seconds_count[5m])
```

**Active Connections**
```promql
devops_demo_active_connections
```

**CPU Usage**
```promql
rate(devops_demo_process_cpu_user_seconds_total[1m]) * 100
```

**Memory Usage (MB)**
```promql
devops_demo_process_resident_memory_bytes / 1024 / 1024
```

**HTTP Status Code Distribution**
```promql
sum by(status_code) (rate(devops_demo_http_requests_total[5m]))
```

## 🧪 Testing the Metrics

### Generate Traffic

```bash
# Health check
curl http://localhost:3000/healthz

# API status
curl http://localhost:3000/api/status

# Generate load (requires bash/git-bash on Windows)
for i in {1..100}; do curl http://localhost:3000/healthz; done
```

### View Raw Metrics

```bash
curl http://localhost:3000/metrics
```

## 🛠️ Configuration Files

### prometheus.yml
Located in project root. Defines:
- Scrape interval: 15 seconds
- Scrape targets: backend API
- Metric labels: service, environment, version

### Backend Metrics Configuration
Located in `backend/index.js`:
- Registry setup
- Default metrics collection
- Custom metrics definitions
- Metrics middleware

## 📚 Best Practices

### 1. Metric Naming
- Use descriptive names with units
- Follow format: `namespace_subsystem_metric_unit`
- Example: `devops_demo_http_request_duration_seconds`

### 2. Label Usage
- Keep cardinality low (avoid user IDs, timestamps)
- Use meaningful labels (method, route, status_code)
- Don't create too many unique label combinations

### 3. Dashboard Design
- Group related metrics
- Use appropriate visualization types
- Set meaningful time ranges
- Add alert thresholds

### 4. Alerting
Add alerts for:
- High error rate (5xx responses)
- Slow response times (p95 > threshold)
- High memory usage
- High CPU usage

## 🔧 Troubleshooting

### Prometheus Can't Scrape Backend

**Problem**: Target shows as DOWN in Prometheus

**Solutions**:
1. Check backend is running: `docker-compose ps`
2. Verify metrics endpoint: `curl http://localhost:3000/metrics`
3. Check Docker network: `docker network inspect devops_demo_devops-network`
4. View Prometheus logs: `docker-compose logs prometheus`

### Grafana Can't Connect to Prometheus

**Problem**: Data source test fails

**Solutions**:
1. Use URL: `http://prometheus:9090` (not localhost)
2. Check both containers are on same network
3. Verify Prometheus is running: `docker-compose ps prometheus`

### Metrics Not Showing in Grafana

**Problem**: Queries return no data

**Solutions**:
1. Generate traffic to the backend API
2. Verify time range in Grafana (last 5-15 minutes)
3. Check metric names are correct
4. Verify Prometheus is scraping: http://localhost:9090/targets

### Memory/CPU Metrics Not Available

**Problem**: Node.js system metrics not appearing

**Solutions**:
1. Wait 15-30 seconds for first scrape
2. Verify `prom-client` is installed: `npm list prom-client`
3. Check default metrics are registered in code

## 🌐 Production Considerations

### Security
- Change Grafana admin password
- Enable authentication on Prometheus
- Use HTTPS for external access
- Restrict network access

### Performance
- Adjust scrape intervals based on traffic
- Set appropriate retention periods
- Use recording rules for complex queries
- Monitor Prometheus resource usage

### High Availability
- Run multiple Prometheus instances
- Use Prometheus federation
- Enable Grafana clustering
- Implement backup strategies

## 📖 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [prom-client GitHub](https://github.com/siimon/prom-client)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Grafana Dashboard Gallery](https://grafana.com/grafana/dashboards/)

## 🎓 Learning Path

1. **Beginner**: View metrics in Prometheus, create basic Grafana dashboard
2. **Intermediate**: Write PromQL queries, create alerts, custom metrics
3. **Advanced**: Recording rules, federation, long-term storage integration

---

**Need Help?** Check the logs:
```bash
docker-compose logs -f backend
docker-compose logs -f prometheus
docker-compose logs -f grafana
```
