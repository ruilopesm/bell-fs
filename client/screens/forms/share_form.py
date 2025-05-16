import traceback
import functools
from json import dumps
from typing import Callable, Coroutine
from textual.reactive import reactive
from textual.message import Message
from textual.screen import Screen
from textual.app import ComposeResult
from textual.containers import Horizontal
from textual.widgets import Checkbox, Button, Label, Input
from textual.containers import HorizontalGroup, VerticalScroll
from api.exceptions import UnauthorizedAccessException


class SharedEntry(HorizontalGroup):

    class Delete(Message):
        def __init__(self, username : str):
            self.username = username
            super().__init__()

    def __init__(self, username : str, permissions : list) -> None:
        self.username = username
        self.permissions = permissions
        super().__init__(id=username)

    def compose(self) -> ComposeResult:
        yield Label(self.username, classes='filename-label')
        for permission in self.permissions:
            if self.permissions[permission]:
                yield Label(permission, classes='filename-label')
        yield Button('Delete', variant='error', id='delete-permission')

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'delete-permission':
            self.post_message(self.Delete(self.username))


class ShareForm(Screen):

    permissions = reactive({})

    def __init__(self, resource_id : str, type : str) -> None:
        super().__init__()
        self.type = type
        self.resource_id = resource_id


    def compose(self) -> ComposeResult:
        yield Input(placeholder='Username', id='user-selector')
        with Horizontal(classes='permissions-group'):
            yield Checkbox('Read', id='read-permission')
            yield Checkbox('Write', id='write-permission')
            yield Checkbox('Append', id='append-permission', disabled=(self.type == 'directory'))
            yield Button('Add', variant='primary', id='add-permission-button')
        yield VerticalScroll(classes='users-permissions', id='users-permissions-id')
        yield Button('Back', variant='primary', id='share-back-button')


    async def on_mount(self) -> None:
        if self.type == 'file':
            self.run_worker(self.load_file_permissions(), exclusive=True)
        elif self.type == 'directory':
            self.run_worker(self.load_directory_permissions(), exclusive=True)


    async def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'share-back-button':
            self.app.pop_screen()
        elif event.button.id == 'add-permission-button':
            if self.type == 'file':
                self.run_worker(self.handle_add_file_permissions(), exclusive=True)
            elif self.type == 'directory':
                self.run_worker(self.handle_add_directory_permissions(), exclusive=True)


    async def on_shared_entry_delete(self, message: SharedEntry) -> None:
        if self.type == 'file':
            self.run_worker(self.handle_delete_file_permissions(message.username), exclusive=True)
        elif self.type == 'directory':
            self.run_worker(self.handle_delete_directory_permissions(message.username), exclusive=True)


    def safe_api_callback(error_title: str = 'API Error'):
        def decorator(func: Callable[..., Coroutine]):
            @functools.wraps(func)
            async def wrapper(self, *args, **kwargs):
                try:
                    return await func(self, *args, **kwargs)
                except UnauthorizedAccessException:
                    self.notify(traceback.format_exc(), title='Unauthorized Access', markup=False)
                    self.app.pop_screen()
                except Exception:
                    self.notify(traceback.format_exc(), title=error_title, severity='error', markup=False)
            return wrapper
        return decorator


    @safe_api_callback('Load File Permissions Failed')
    async def load_file_permissions(self) -> None:
        response = await self.app.api.get_users_with_file_access(self.resource_id)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        self.permissions = response.json()
        self.load_permissions_widgets()


    @safe_api_callback('Load Direcotry Permissions Failed')
    async def load_directory_permissions(self) -> None:
        response = await self.app.api.get_users_with_directory_access(self.resource_id)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        self.permissions = response.json()
        self.load_permissions_widgets()


    @safe_api_callback('Add File Permissions Failed')
    async def handle_add_file_permissions(self) -> None:
        self.check_add()
        username = self.query_one('#user-selector').value
        permissions = {
            'read': self.query_one('#read-permission').value,
            'write': self.query_one('#write-permission').value,
            'append':  self.query_one('#append-permission').value,
        }
        self.permissions['metadatas'].append({
            'username': username,
            'permissions': permissions
        })
        response = await self.app.api.post_file_share_permission(self.resource_id, username, permissions)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        share_entry = SharedEntry(username, permissions)
        self.query_one('#users-permissions-id').mount(share_entry)
        share_entry.scroll_visible()


    @safe_api_callback('Add Directory Permissions Failed')
    async def handle_add_directory_permissions(self) -> None:
        self.check_add()
        username = self.query_one('#user-selector').value
        permissions = {
            'read': self.query_one('#read-permission').value,
            'write': self.query_one('#write-permission').value,
            'append':  self.query_one('#append-permission').value,
        }
        self.permissions['metadatas'].append({
            'username': username,
            'permissions': permissions
        })
        response = await self.app.api.put_directory_share_permission(self.resource_id, username, permissions)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        share_entry = SharedEntry(username, permissions)
        self.query_one('#users-permissions-id').mount(share_entry)
        share_entry.scroll_visible()


    @safe_api_callback('Delete File Permissions Failed')
    async def handle_delete_file_permissions(self, username: str) -> None:
        response = await self.app.api.delete_file_share_permission(self.resource_id, username)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        await self.load_file_permissions()


    @safe_api_callback('Delete Directory Permissions Failed')
    async def handle_delete_directory_permissions(self, username) -> None:
        response = await self.app.api.delete_directory_share_permission(self.resource_id, username)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        await self.load_directory_permissions()


    def load_permissions_widgets(self) -> None:
        share_entries = self.query_one('#users-permissions-id')
        share_entries.remove_children()
        share_entries._nodes._clear()
        self.notify(dumps(self.permissions), markup=False)
        for permission in self.permissions['metadatas']:
            share_entry = SharedEntry(permission['username'], permission['permissions'])
            share_entries.mount(share_entry)
            share_entry.scroll_visible()


    def on_checkbox_changed(self, event: Checkbox.Changed) -> None:
        checkbox = event.control
        if self.type == 'file':
            if checkbox.id == 'write-permission' and checkbox.value:
                self.query_one('#read-permission').value = True
            if checkbox.id == 'read-permission' and not checkbox.value:
                self.query_one('#write-permission').value = False


    def check_add(self) -> None:
        user = self.query_one('#user-selector').value
        read_permission = self.query_one('#read-permission').value
        write_permission = self.query_one('#write-permission').value
        append_permission = self.query_one('#append-permission').value
        if not (read_permission or write_permission or append_permission):
            raise Exception('You havent selected any permission')
        if user == '' or user in [metadata['username'] for metadata in self.permissions['metadatas']]:
            raise Exception('BLANK user or already present in shares')