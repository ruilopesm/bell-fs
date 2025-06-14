import webbrowser
import traceback
from textual.reactive import reactive
from textual.message import Message
from textual.app import ComposeResult
from textual.widgets import Input, Button, Static, DirectoryTree


class RegisterForm(Static):

    current_device_code = reactive(None)

    class RegisterSuccess(Message):
        def __init__(self) -> None:
            super().__init__()

    def compose(self) -> ComposeResult:
        self.certificate_path = None
        self.username = Input(placeholder='Username', classes='register-form-input')
        self.password = Input(placeholder='Password', password=True, classes='register-form-input')
        self.register_btn = Button('Register', id='registerButton', variant='primary')
        self.directory_tree = DirectoryTree('./', id='cert-explorer')
        yield self.username
        yield self.password
        yield self.directory_tree
        yield self.register_btn

    def on_directory_tree_file_selected(self, message: DirectoryTree.FileSelected) -> None:
        self.certificate_path = message.path

    async def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'registerButton':
            self.run_worker(self.handle_register(), exclusive=True)
  
    async def handle_register(self):
        try:
            response = await self.app.api.register(
                self.username.value,
                self.password.value,
                self.certificate_path
            )
            webbrowser.open_new_tab(response.json().get('totp_qr'))
            self.notify('Login to access BLP file system', title='Successful Registration')
            self.post_message(self.RegisterSuccess())
        except Exception as e:
            self.notify(str(traceback.format_exc()), markup=False)
            self.notify(str(e), title='Failed Registration', markup=False, severity='error')