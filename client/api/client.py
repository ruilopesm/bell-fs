from api.auth import AsyncAuthAPIClient
from api.blpfs import AsyncBLPFSAPIClient


class AsyncAPIClient:

    def __init__(self, base_url):
        self.auth_client = AsyncAuthAPIClient(base_url)
        self.blpfs_client = AsyncBLPFSAPIClient(self.auth_client)

    async def register(self, username, password, certificate):
        return await self.auth_client.register(username, password, certificate)

    async def login(self, username, password):
        return await self.auth_client.login(username, password)

    async def logout(self):
        return await self.auth_client.logout()

    async def refresh(self):
        return await self.auth_client.refresh()

    async def me(self):
        return await self.blpfs_client.me()