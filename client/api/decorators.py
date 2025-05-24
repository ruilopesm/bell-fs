import base64
from json import dumps
from functools import wraps
from collections import OrderedDict
from typing import Callable, Coroutine
from crypto.rsa import rsa_sign
from api.exceptions import UnauthorizedAccessException


def api_call(expected_status: int, method: str):
    def decorator(func):
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            url, payload = await func(self, *args, **kwargs)
            method_func = getattr(self.auth_client, method.lower(), None)

            if not method_func:
                raise ValueError(f'Unsupported HTTP method: {method}')

            request_args = {'params' if method.lower() == 'get' else 'json': payload}
            response = await method_func(url, **request_args)

            if response.status_code != expected_status:
                try:
                    error_content = response.json()
                except Exception:
                    error_content = {'error': 'Invalid JSON in response'}
                raise Exception(dumps({
                    'status_code': response.status_code,
                    'error': error_content
                }))

            return response
        return wrapper
    return decorator


def secure_api_call(expected_status: int, method: str):
    def decorator(func):
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            path, payload = await func(self, *args, **kwargs)
            request_func = getattr(self.auth_client, method.lower(), None)

            signature_content = OrderedDict([
                ('path', path),
                ('method', method.lower())
            ])

            if method.lower() != 'get' and payload:
                signature_content['body'] = payload

            signature = rsa_sign(
                self.private_key,
                base64.b64encode(dumps(signature_content).encode('utf-8'))
            )

            headers = {
                'Authorization': f'Bearer {self.auth_api.access_token}',
                'X-Signature': base64.b64encode(signature).decode('utf-8')
            }

            request_args = {
                'headers': headers,
                'params' if method.lower() == 'get' else 'json': payload
            }

            if request_func is None:
                raise ValueError(f'Unsupported HTTP method: {method}')

            response = await request_func(path, **request_args)

            if response.status_code == 401:
                await self.auth_api.refresh()
                headers['Authorization'] = f'Bearer {self.auth_api.access_token}'
                request_args['headers'] = headers
                response = await request_func(path, **request_args)

            if response.status_code == 401:
                raise UnauthorizedAccessException()

            if response.status_code != expected_status:
                try:
                    error_content = await response.json()
                except Exception:
                    error_content = {'error': 'Invalid JSON in response'}
                raise Exception(dumps({
                    'status_code': response.status_code,
                    'error': error_content
                }))

            return response
        return wrapper
    return decorator


def safe_api_callback(error_title: str):
    def decorator(func: Callable[..., Coroutine]):
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            try:
                return await func(self, *args, **kwargs)
            except UnauthorizedAccessException as e:
                self.notify(str(e), title='Unauthorized Access', severity='error', markup=False)
            except Exception as e:
                self.notify(str(e), title=error_title, severity='error', markup=False)
        return wrapper
    return decorator