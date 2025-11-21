import unittest
import app as test_app

class FlaskAppTests(unittest.TestCase):
    def setUp(self):
        self.app = test_app.app.test_client()

    def test_get_hello_endpoint(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_data(), b'Hello world from app Pipeline testing.')

if __name__ == '__main__':
    unittest.main()
