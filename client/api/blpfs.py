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
        return f'/me', {}

    @secure_api_call(expected_status=200, method='get')
    async def get_files(self):
        return f'/files', {}

    @secure_api_call(expected_status=200, method='get')
    async def read_file(self, file_id):
        return f'/files/{file_id}', {}

    @secure_api_call(expected_status=201, method='post')
    async def create_file(self, name, content, compartment, confidentiality, integrity):
        return f'/files', {
           'file': {
                'name': name,
                'content': content,
                'compartment': compartment,
                'confidentiality': confidentiality,
                'integrity': integrity,
           }
        }

    @secure_api_call(expected_status=200, method='put')
    async def update_file_content(self, file_id, name, content):
        return f'/files/{file_id}', {
            'file': {
                'name': name,
                'content': content,
            }
        }

    @secure_api_call(expected_status=204, method='delete')
    async def delete_file(self, file_id):
        return f'/files/{file_id}', {}

    @secure_api_call(expected_status=200, method='put')
    async def update_confidentiality(self, file_id, confidentiality):
        return f'/files/{file_id}/confidentiality', {
            'confidentiality': confidentiality
        }

    @secure_api_call(expected_status=200, method='put')
    async def update_integrity(self, file_id, integrity):
        return f'/files/{file_id}/integrity', {
            'integrity': integrity
        }

    @secure_api_call(expected_status=200, method='get')
    async def list_compartments(self):
        return f'/compartments', {}

    @secure_api_call(expected_status=200, method='get')
    async def list_levels(self):
        return f'/levels', {}