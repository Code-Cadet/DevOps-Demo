const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const DB_PASSWORD = process.env.DATABASE_PASSWORD || 'default_password';

app.use(express.json());

// Root endpoint - API information
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps Demo Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/healthz',
      ready: '/ready',
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