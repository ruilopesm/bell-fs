from textual.app import ComposeResult
from textual.widgets import Input, Button, Static
from textual.message import Message


class LoginForm(Static):

    class LoginSuccess(Message):
        def __init__(self):
            super().__init__()

    def compose(self) -> ComposeResult:
        self.username = Input(placeholder='Username', classes='login-form-input')
        self.password = Input(placeholder='Password', password=True, classes='login-form-input')
        self.login_btn = Button('Login', id='loginButton', variant='primary')
        yield self.username
        yield self.password
        yield self.login_btn

    async def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'loginButton':
            self.run_worker(self.handle_login(), exclusive=True)

    async def handle_login(self) -> None:
        try:
            await self.app.api.login('diogo', 'portugal1234')
            self.post_message(self.LoginSuccess())
        except Exception as e:
            self.notify(str(e), title='Failed Login', markup=False, severity='error')