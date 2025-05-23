from functools import wraps
from json import dumps

def auth_api_call(expected_status):
    def decorator(func):
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            url, payload = await func(self, *args, **kwargs)
            response = await self.auth_client.post(url, json=payload)

            if response.status_code != expected_status:
                raise Exception(dumps(response.json()))

            return response
        return wrapper
    return decorator