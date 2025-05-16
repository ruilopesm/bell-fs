from api.auth import AsyncAuthAPIClient
from api.blpfs import AsyncBLPFSAPIClient


class AsyncAPIClient:

    def __init__(self, base_url):
        self.auth_client = AsyncAuthAPIClient(base_url)
        self.blpfs_client = AsyncBLPFSAPIClient(base_url, self.auth_client)