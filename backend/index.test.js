const request = require('supertest');
const app = require('./index');

let server;

beforeAll(() => {
  // Start server on a random port for testing
  server = app.listen(0);
});

afterAll((done) => {
  // Properly close server after all tests
  server.close(done);
});

describe('Backend API Tests', () => {
  describe('GET /healthz', () => {
    it('should return healthy status', async () => {
      const response = await request(server)
        .get('/healthz')
        .expect(200);
      
      expect(response.body).toEqual({ status: 'healthy' });
    });
  });

  describe('GET /ready', () => {
    it('should return ready status', async () => {
      const response = await request(server)
        .get('/ready')
        .expect(200);
      
      expect(response.body).toEqual({ status: 'ready' });
    });
  });

  describe('GET /', () => {
    it('should return API information', async () => {
      const response = await request(server)
        .get('/')
        .expect(200);
      
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('endpoints');
    });
  });

  describe('GET /api/status', () => {
    it('should return system status', async () => {
      const response = await request(server)
        .get('/api/status')
        .expect(200);
      
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body.environment).toBe('test');
    });
  });

  describe('GET /metrics', () => {
    it('should return Prometheus metrics', async () => {
      const response = await request(server)
        .get('/metrics')
        .expect(200);
      
      expect(response.text).toContain('# HELP');
      expect(response.text).toContain('# TYPE');
      expect(response.text).toContain('devops_demo_');
      expect(response.headers['content-type']).toMatch(/^text\/plain/);
    });

    it('should include custom HTTP metrics', async () => {
      // Make a request to generate metrics
      await request(server).get('/healthz');
      
      const response = await request(server)
        .get('/metrics')
        .expect(200);
      
      expect(response.text).toContain('devops_demo_http_requests_total');
      expect(response.text).toContain('devops_demo_http_request_duration_seconds');
    });
  });
});