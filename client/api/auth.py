import httpx
from api.decorators import api_call
from crypto.certificate import serialize_ceritifcate_to_base64, certificate_load


class AsyncAuthAPIClient:

    def __init__(self, base_url):
        self.username = None
        self.access_token = None
        self.refresh_token = None
        self.auth_client = httpx.AsyncClient(base_url=base_url)

    @api_call(expected_status=201, method='post')
    async def _register(self, username, password, certificate):
        return '/register', {
            'user': {
                'username': username,
                'password': password,
                'certificate': serialize_ceritifcate_to_base64(
                    certificate_load(certificate)),
            }
        }

    @api_call(expected_status=200, method='post')
    async def _login(self, username, password):
        return '/login', {
            'username': username,
            'password': password,
        }

    @api_call(expected_status=204, method='post')
    async def _logout(self):
        return '/logout', {
            'refresh_token': self.refresh_token,
        }

    @api_call(expected_status=201, method='post')
    async def _refresh(self):
        return '/refresh', {
            'refresh_token': self.refresh_token,
        }

    async def register(self, username, password, certificate):
        return await self._register(username, password, certificate)

    async def login(self, username, password):
        response = await self._login(username, password)
        body = response.json()
        self.username = body['user']['username']
        self.access_token = body['access_token']
        self.refresh_token = body['refresh_token']
        return response

    async def logout(self):
        response = await self._logout()
        self.username = None
        self.access_token = None
        self.refresh_token = None
        return response

    async def refresh(self):
        response =  await self._refresh()
        body = response.json()
        self.access_token = body['access_token']
        self.refresh_token = body['refresh_token']
        return response