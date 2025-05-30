from api.auth import AsyncAuthAPIClient
from api.blpfs import AsyncBLPFSAPIClient


class AsyncAPIClient:

    def __init__(self, base_url):
        self.auth_client = AsyncAuthAPIClient(base_url)
        self.blpfs_client = AsyncBLPFSAPIClient(self.auth_client)

    async def register(self, username, password, certificate):
        return await self.auth_client.register(username, password, certificate)

    async def login(self, username, password, totp_code):
        return await self.auth_client.login(username, password, totp_code)

    async def logout(self):
        return await self.auth_client.logout()

    async def refresh(self):
        return await self.auth_client.refresh()

    async def me(self):
        return await self.blpfs_client.me()

    async def get_files(self):
        return await self.blpfs_client.get_files()

    async def read_file(self, file_id):
        return await self.blpfs_client.read_file(file_id)

    async def create_file(self, name, content, compartment, confidentiality, integrity):
        return await self.blpfs_client.create_file(name, content, compartment, confidentiality, integrity)

    async def update_file_content(self, file_id, name, content):
        return await self.blpfs_client.update_file_content(file_id, name, content)

    async def delete_file(self, file_id):
        return await self.blpfs_client.delete_file(file_id)

    async def update_confidentiality(self, file_id, confidentiality):
        return await self.blpfs_client.update_confidentiality(file_id, confidentiality)

    async def update_integrity(self, file_id, integrity):
        return await self.blpfs_client.update_integrity(file_id, integrity)

    async def list_compartments(self):
        return await self.blpfs_client.list_compartments()

    async def list_levels(self):
        return await self.blpfs_client.list_levels()