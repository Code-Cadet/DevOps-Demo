const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware for JSON parsing
app.use(express.json());

// Health check endpoint for Kubernetes liveness probe
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Readiness check endpoint for Kubernetes readiness probe
app.get('/ready', (req, res) => {
  // Add any readiness checks here (e.g., database connectivity)
  res.status(200).json({ status: 'ready' });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'DevOps Demo Backend API',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Sample API endpoint
app.get('/api/status', (req, res) => {
  res.json({
    uptime: process.uptime(),
    timestamp: Date.now(),
    database: process.env.DATABASE_PASSWORD ? 'configured' : 'not configured'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Backend server running on http://localhost:${port}`);
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

module.exports = app;