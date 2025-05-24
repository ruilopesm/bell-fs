from os import getenv
from api.auth import AsyncAuthAPIClient
from crypto.rsa import load_private_key
from api.decorators import secure_api_call


class AsyncBLPFSAPIClient:

    def __init__(self, auth_api: AsyncAuthAPIClient):
        self.certificate = None
        self.auth_api = auth_api
        self.auth_client = auth_api.auth_client
        self.private_key = load_private_key(getenv('PRIVATE_KEY', None))

    @secure_api_call(expected_status=200, method='get')
    async def me(self):
        return '/me', {}