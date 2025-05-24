import json
from api.decorators import safe_api_callback
from textual.screen import Screen
from textual.widgets import Footer
from textual.reactive import reactive
from textual.app import ComposeResult
from textual.containers import VerticalScroll
from screens.text.editor import EditorScreen
from screens.forms.file_form import FileForm
from screens.resources.file import File
from screens.forms.manage_form  import ManageForm


class BLPFS(Screen):

    CSS_PATH = '../style/blpfs.tcss'
    BINDINGS = [
        ('a', 'add_file', 'add file'),
        ('q', 'logout', 'logout'),
        ('m', 'me', 'me'),
    ]

    current_directory = reactive(None)
    current_directory_data = reactive(None)


    def compose(self) -> ComposeResult:
        yield VerticalScroll(id='blpfs')
        yield Footer()


    async def on_mount(self) -> None:
        with open('assets/blpfs.json') as file:
            self.fs = json.load(file)
            self.load_blpfs_widgets()


    async def action_logout(self) -> None:
        self.run_worker(self.handle_logout(), exclusive=True)

    async def action_me(self) -> None:
        self.run_worker(self.handle_me(), exclusive=True)


    async def action_add_file(self) -> None:
        def handler(filename : str | None) -> None:
            self.notify(str(filename))
        self.app.push_screen(FileForm(), handler)


    async def on_file_read(self, message: File.Read) -> None:
        self.run_worker(self.handle_file_read(message.resource_id), exclusive=True)


    async def on_file_write(self, message: File.Write) -> None:
        self.run_worker(self.handle_file_write(message.resource_id), exclusive=True)


    async def on_file_manage(self, message: File.Manage) -> None:
        def handler(filename : str | None) -> None:
            self.notify(str(filename))
        self.app.push_screen(ManageForm(), handler)



    async def on_file_delete(self, message: File.Delete) -> None:
        self.run_worker(self.handle_file_delete(message.resource_id), exclusive=True)


    @safe_api_callback('File Register Failed')
    async def handle_file_form_dismiss(self, filename : str | None) -> None:
        with open(filename, 'rb') as file:
            response = await self.app.api.post_file_create(
                filename.split('/')[-1],
                file.read(),
                self.current_directory)
            if response.status_code != 201:
                raise Exception(json.dumps(response.json()))
            file_resource = File(
                response.json().get('file').get('id'),
                response.json().get('file').get('name'))
            resources = self.query_one('#blpfs')
            resources.mount(file_resource)
            file_resource.scroll_visible()


    @safe_api_callback('Write File Failed')
    async def handle_file_write(self, file_id: str) -> None:
        async def handler(new_content : str | None) -> None:
            write_response = await self.app.api.post_file_write(
                file_id, body, new_content.encode('utf-8'))
            if write_response.status_code != 200:
                raise Exception(json.dumps(write_response.json()))
        response = await self.app.api.get_file(file_id)
        if response.status_code != 200:
            raise Exception(json.dumps(response.json()))
        body = response.json()
        name = body['file']['name']
        content = await self.app.api.get_file_content(body)
        self.app.push_screen(EditorScreen(name, content.decode('utf-8')), handler)


    @safe_api_callback('Delete File Failed')
    async def handle_file_manage(self, file_id : str):
        response = await self.app.api.delete_file(file_id)
        if response.status_code != 204:
            raise Exception(json.dumps(response.json()))
        await self.load_blpfs()


    @safe_api_callback('Delete File Failed')
    async def handle_file_delete(self, file_id : str):
        response = await self.app.api.delete_file(file_id)
        if response.status_code != 204:
            raise Exception(json.dumps(response.json()))
        await self.load_blpfs()


    @safe_api_callback('Failed Logout')
    async def handle_logout(self) -> None:
        await self.app.api.logout()
        self.app.pop_screen()
        self.notify('Login again to access BLP file system', title='Successful Logout')


    @safe_api_callback('Failed get ME')
    async def handle_me(self) -> None:
        response = await self.app.api.me()
        self.notify(json.dumps(response.json()), markup=False)


    @safe_api_callback('Load Directory Failed')
    async def load_blpfs(self) -> None:
        if self.current_directory == None:
            response = await self.app.api.get_vault()
        else:
            response = await self.app.api.get_directory(self.current_directory)
        if response.status_code != 200:
            raise Exception(json.dumps(response.json()))
        self.current_directory_data = response.json()
        self.notify(json.dumps(self.current_directory_data), markup=False)
        self.load_blpfs_widgets()


    def load_blpfs_widgets(self) -> None:
        resources = self.query_one('#blpfs')
        resources.remove_children()
        resources._nodes._clear()
        for file in self.fs:
            resources.mount(File(file))