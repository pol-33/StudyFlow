from django.test import TestCase, Client

class SmokeTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_root_urls(self):
        r = self.client.get('/api/')
        self.assertIn(r.status_code, [200, 301, 302, 404])

    def test_jwt_endpoints_exist(self):
        r = self.client.options('/api/auth/token/')
        self.assertIn(r.status_code, [200, 204, 405])