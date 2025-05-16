import httpx


class AsyncAuthAPIClient:

    def __init__(self, base_url):
        self.username = None
        self.access_token = None
        self.refresh_token = None
        self.auth_client = httpx.AsyncClient(base_url=base_url)