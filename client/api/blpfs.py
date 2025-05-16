import httpx
import base64
from json import dumps
from os import getenv
from collections import OrderedDict
from api.auth import AsyncAuthAPIClient
from api.exceptions import UnauthorizedAccessException
from crypto.rsa import load_private_key, rsa_sign


class AsyncBLPFSAPIClient:

    def __init__(self, base_url, auth_api: AsyncAuthAPIClient):
        self.auth_client = auth_api
        self.certificate = None
        self.private_key = load_private_key(getenv('PRIVATE_KEY', None))
        self.blpfs_client = httpx.AsyncClient(base_url=base_url)

    async def request_with_token_refresh(self, method, path, **kwargs):

        signature_content = OrderedDict([
            ('path', path),
            ('method', method.__name__)
        ])

        if 'json' in kwargs:
            signature_content['body'] = kwargs.get('json')

        signature = rsa_sign(
            self.private_key,
            base64.b64encode(dumps(signature_content).encode('utf-8'))
        )

        headers = kwargs.get('headers', {})
        headers['Authorization'] = f'Bearer {self.auth_client.access_token}'
        kwargs['headers'] = headers
        headers['X-Signature'] = base64.b64encode(signature).decode('utf-8')

        response = await method(path, **kwargs)

        if response.status_code == 401:
            await self.auth_client.post_refresh_token()
            headers['Authorization'] = f'Bearer {self.auth_client.access_token}'
            kwargs['headers'] = headers
            response = await method(path, **kwargs)

        if response.status_code == 401:
            raise UnauthorizedAccessException()

        return response