from os import getenv
from client_app import ClientApp
from api.client import AsyncAPIClient


if __name__ == '__main__':
    base_url = getenv('BASE_URL', 'http://localhost:4000')
    app = ClientApp(AsyncAPIClient(base_url))
    app.run()