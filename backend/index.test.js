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
});