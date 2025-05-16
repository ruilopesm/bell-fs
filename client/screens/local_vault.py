from json import dumps
import traceback
import functools
from typing import Callable, Coroutine
from textual.screen import Screen
from textual.widgets import Footer
from textual.reactive import reactive
from textual.app import ComposeResult
from textual.containers import VerticalScroll
from screens.remote_vault import RemoteVault
from screens.text.editor import EditorScreen
from screens.forms.file_form import FileForm
from screens.forms.share_form import ShareForm
from screens.forms.directory_form import DirectoryForm
from screens.resources.local.file_resource import FileResource
from screens.resources.local.directory_resource import DirectoryResource
from api.exceptions import UnauthorizedAccessException


class LocalVault(Screen):

    CSS_PATH = '../resources/vault.tcss'
    BINDINGS = [
        ('a', 'add_file', 'add file'),
        ('s', 'add_directory', 'add directory'),
        ('d', 'back_directory', 'parent directory'),
        ('r', 'remote_vault', 'remote vault'),
        ('q', 'logout', 'logout')
    ]

    current_directory = reactive(None)
    current_directory_data = reactive(None)


    def compose(self) -> ComposeResult:
        yield VerticalScroll(id='local-vault-resources')
        yield Footer()


    async def on_mount(self) -> None:
        self.run_worker(self.load_current_directory(), exclusive=True)


    def action_remote_vault(self) -> None:
        self.app.push_screen(RemoteVault())


    async def action_logout(self) -> None:
        self.run_worker(self.handle_logout(), exclusive=True)


    async def action_back_directory(self) -> None:
        self.current_directory = self.current_directory_data.get('directory', {}).get('parent_directory_id', None)
        self.run_worker(self.load_current_directory(), exclusive=True)


    async def action_add_file(self) -> None:
        self.run_worker(self.app.push_screen(FileForm(), self.handle_file_form_dismiss), exclusive=True)


    async def action_add_directory(self) -> None:
        self.run_worker(self.app.push_screen(DirectoryForm(), self.handle_directory_form_dismiss), exclusive=True)


    async def on_file_resource_edit(self, message: FileResource.Edit) -> None:
        self.run_worker(self.handle_file_resource_edit(message.resource_id), exclusive=True)


    async def on_directory_resource_enter(self, message: DirectoryResource.Enter) -> None:
        self.current_directory = message.resource_id
        self.run_worker(self.load_current_directory(), exclusive=True)


    def on_file_resource_share(self, message: FileResource.Share) -> None:
        self.app.push_screen(ShareForm(message.resource_id, 'file'))


    def on_directory_resource_share(self, message: FileResource.Share) -> None:
        self.app.push_screen(ShareForm(message.resource_id, 'directory'))


    def on_file_resource_delete(self, message: FileResource.Delete) -> None:
        self.run_worker(self.handle_file_delete(message.resource_id), exclusive=True)


    async def on_directory_resource_delete(self, message: DirectoryResource.Delete) -> None:
        self.run_worker(self.handle_directory_delete(message.resource_id), exclusive=True)


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


    @safe_api_callback('Edit File Content Failed')
    async def handle_file_resource_edit(self, file_id: str) -> None:
        async def handler(new_content : str | None) -> None:
            write_response = await self.app.api.post_file_write(
                file_id, body, new_content.encode('utf-8'))
            if write_response.status_code != 200:
                raise Exception(dumps(write_response.json()))
        response = await self.app.api.get_file(file_id)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        body = response.json()
        name = body['file']['name']
        content = await self.app.api.get_file_content(body)
        self.app.push_screen(EditorScreen(name, content.decode('utf-8')), handler)


    @safe_api_callback('File Register Failed')
    async def handle_file_form_dismiss(self, filename : str | None) -> None:
        with open(filename, 'rb') as file:
            response = await self.app.api.post_file_create(
                filename.split('/')[-1],
                file.read(),
                self.current_directory)
            if response.status_code != 201:
                raise Exception(dumps(response.json()))
            file_resource = FileResource(
                response.json().get('file').get('id'),
                response.json().get('file').get('name'))
            resources = self.query_one('#local-vault-resources')
            resources.mount(file_resource)
            file_resource.scroll_visible()


    @safe_api_callback('Directory Register Failed')
    async def handle_directory_form_dismiss(self, directory : str | None) -> None:
        if directory != None:
            response = await self.app.api.post_directory(directory, self.current_directory)
            if response.status_code != 201:
                    raise Exception(dumps(response.json()))
            directory_resource = DirectoryResource(
                response.json().get('directory').get('id'),
                response.json().get('directory').get('name'))
            resources = self.query_one('#local-vault-resources')
            resources.mount(directory_resource)
            directory_resource.scroll_visible()


    @safe_api_callback('Logout Failed')
    async def handle_logout(self) -> None:
        response = await self.app.api.logout()
        if response.status_code != 204:
            raise Exception(dumps(response.json()))
        self.app.pop_screen()
        self.notify('Login again to access vault', title='Successful Logout')


    @safe_api_callback('Delete File Failed')
    async def handle_file_delete(self, file_id : str):
        response = await self.app.api.delete_file(file_id)
        if response.status_code != 204:
            raise Exception(dumps(response.json()))
        await self.load_current_directory()


    @safe_api_callback('Delete Directory Failed')
    async def handle_directory_delete(self, directory_id : str):
        response = await self.app.api.delete_directory(directory_id)
        if response.status_code != 204:
            raise Exception(dumps(response.json()))
        await self.load_current_directory()


    @safe_api_callback('Load Directory Failed')
    async def load_current_directory(self) -> None:
        if self.current_directory == None:
            response = await self.app.api.get_vault()
        else:
            response = await self.app.api.get_directory(self.current_directory)
        if response.status_code != 200:
            raise Exception(dumps(response.json()))
        self.current_directory_data = response.json()
        self.notify(dumps(self.current_directory_data), markup=False)
        self.load_current_directory_widgets()


    def load_current_directory_widgets(self) -> None:
        resources = self.query_one('#local-vault-resources')
        resources.remove_children()
        resources._nodes._clear()
        file_list = (
            self.current_directory_data.get('files', []) +
            self.current_directory_data.get('directory', {}).get('files', []))
        directory_list = (
            self.current_directory_data.get('directories', []) +
            self.current_directory_data.get('directory', {}).get('subdirectories', []))
        for directory in directory_list:
            resources.mount(DirectoryResource(directory['id'], directory['name']))
        for file in file_list:
            resources.mount(FileResource(file['id'], file['name']))