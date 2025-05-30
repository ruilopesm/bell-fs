import json
import base64
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
from screens.text.viewer import ViewerScreen


class BLPFS(Screen):

    CSS_PATH = '../style/blpfs.tcss'
    BINDINGS = [
        ('a', 'add_file', 'add file'),
        ('q', 'logout', 'logout'),
        ('m', 'me', 'me'),
        ('r', 'reload', 'reload'),
    ]

    files = reactive(None)
    selected_file = reactive(None)

    def compose(self) -> ComposeResult:
        yield VerticalScroll(id='blpfs')
        yield Footer()


    async def on_mount(self) -> None:
        self.run_worker(self.load_blpfs(), exclusive=True)


    async def action_logout(self) -> None:
        self.run_worker(self.handle_logout(), exclusive=True)


    async def action_me(self) -> None:
        self.run_worker(self.handle_me(), exclusive=True)


    async def action_reload(self) -> None:
        self.run_worker(self.load_blpfs(), exclusive=True)


    async def on_file_read(self, message: File.Read) -> None:
        self.run_worker(self.handle_file_read(message.resource_id), exclusive=True)


    async def on_file_write(self, message: File.Write) -> None:
        self.run_worker(self.handle_file_write(message.resource_id), exclusive=True)


    async def on_file_delete(self, message: File.Delete) -> None:
        self.run_worker(self.handle_file_delete(message.resource_id), exclusive=True)


    async def action_add_file(self) -> None:
        self.run_worker(self.handle_file_form(), exclusive=True)


    def on_file_manage(self, message: File.Manage) -> None:
        self.selected_file = message.resource_id
        self.run_worker(self.handle_manage_form(), exclusive=True)


    @safe_api_callback('Manage Form Failed')
    async def handle_manage_form(self) -> None:
        async def handler(result : dict | None) -> None:
            if result['success']:
                await self.handle_update_integrity(self.selected_file, result['integrity'])
                await self.handle_update_confidentiality(self.selected_file, result['confidentiality'])
                await self.load_blpfs()
        self.app.push_screen(ManageForm(), handler)


    @safe_api_callback('Update Integrity Failed')
    async def handle_update_integrity(self, file_id, integrity) -> None:
        await self.app.api.update_integrity(file_id, integrity)


    @safe_api_callback('Update Confidentiality Failed')
    async def handle_update_confidentiality(self, file_id, confidentiality) -> None:
        await self.app.api.update_confidentiality(file_id, confidentiality)


    @safe_api_callback('File Form Failed')
    async def handle_file_form(self) -> None:
        async def handler(filename : str | None) -> None:
            if len(filename) > 0:
                self.notify(filename, title='File Saved')
            await self.load_blpfs()
        self.app.push_screen(FileForm(), handler)


    @safe_api_callback('Delete File Failed')
    async def handle_file_delete(self, file_id: str) -> None:
        await self.app.api.delete_file(file_id)
        response = await self.app.api.get_files()
        self.files = response.json().get('files')
        self.load_blpfs_widgets()


    @safe_api_callback('Write File Failed')
    async def handle_file_write(self, file_id: str) -> None:
        async def handler(new_content : str | None) -> None:
            await self.app.api.update_file_content(file_id, name, new_content)
        response = await self.app.api.read_file(file_id)
        body = response.json()
        name = body['file']['name']
        content = body['file']['content']
        self.app.push_screen(EditorScreen(name, content), handler)


    @safe_api_callback('Read File Failed')
    async def handle_file_read(self, file_id) -> None:
        response = await self.app.api.read_file(file_id)
        body = response.json()
        name = body['file']['name']
        content = body['file']['content']
        self.app.push_screen(ViewerScreen(name, content))


    @safe_api_callback('Failed Logout')
    async def handle_logout(self) -> None:
        await self.app.api.logout()
        self.app.pop_screen()
        self.notify('Login again to access BLP file system', title='Successful Logout')


    @safe_api_callback('Failed Get ME')
    async def handle_me(self) -> None:
        response = await self.app.api.me()
        self.notify(json.dumps(response.json()), markup=False)


    @safe_api_callback('Load blpfs Failed')
    async def load_blpfs(self) -> None:
        response = await self.app.api.get_files()
        self.files = response.json().get('files')
        self.notify(json.dumps(self.files), markup=False)
        self.load_blpfs_widgets()


    def load_blpfs_widgets(self) -> None:
        resources = self.query_one('#blpfs')
        resources.remove_children()
        resources._nodes._clear()
        for file in self.files:
            resources.mount(File(file))