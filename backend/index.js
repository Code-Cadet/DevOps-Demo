const express = require('express');
const promClient = require('prom-client');
const app = express();

const PORT = process.env.PORT || 3000;
const DB_PASSWORD = process.env.DATABASE_PASSWORD || 'default_password';

// Prometheus metrics setup
const register = new promClient.Registry();

// Collect default metrics (CPU, memory, event loop, etc.)
promClient.collectDefaultMetrics({ 
  register,
  prefix: 'devops_demo_'
});

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'devops_demo_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register]
});

const httpRequestCounter = new promClient.Counter({
  name: 'devops_demo_http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const activeConnections = new promClient.Gauge({
  name: 'devops_demo_active_connections',
  help: 'Number of active connections',
  registers: [register]
});

app.use(express.json());

// Metrics middleware - track request duration and count
app.use((req, res, next) => {
  const start = Date.now();
  
  activeConnections.inc();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;
    
    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);
    
    httpRequestCounter
      .labels(req.method, route, res.statusCode)
      .inc();
    
    activeConnections.dec();
  });
  
  next();
});

// Root endpoint - API information
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps Demo Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/healthz',
      ready: '/ready',
      metrics: '/metrics',
      status: '/api/status'
    }
  });
});

// Health check endpoint
app.get('/healthz', (req, res) => {
  res.json({ status: 'healthy' });
});

// Readiness check endpoint
app.get('/ready', (req, res) => {
  res.json({ status: 'ready' });
});

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Status endpoint with system info
app.get('/api/status', (req, res) => {
  res.json({
    status: 'running',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database: {
      configured: !!DB_PASSWORD,
      passwordLength: DB_PASSWORD.length
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Only start server if not being required by tests
if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`Backend server running on http://localhost:${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });

  process.on('SIGINT', () => {
    console.log('SIGINT signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
      process.exit(0);
    });
  });
}

module.exports = app;