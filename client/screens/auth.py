from textual.app import ComposeResult
from textual.screen import Screen
from textual.reactive import reactive
from textual.widgets import Tabs, Tab, Footer
from screens.forms.login_form import LoginForm
from screens.forms.register_form import RegisterForm


class Auth(Screen):

    CSS_PATH = '../style/auth.tcss'
    active_tab = reactive('Login')


    def compose(self) -> ComposeResult:
        yield LoginForm(id='login-form')
        yield RegisterForm(id='register-form')
        yield Tabs(Tab('Login', id='login'), Tab('Register', id='register'), id='tabs')
        yield Footer()


    def on_mount(self) -> None:
        self._update_form_visibility()


    def on_tabs_tab_activated(self, event: Tabs.TabActivated) -> None:
        self.active_tab = str(event.tab.label)
        self._update_form_visibility()


    def _update_form_visibility(self) -> None:
        self.query_one('#login-form').display = self.active_tab == 'Login'
        self.query_one('#register-form').display = self.active_tab == 'Register'


    def on_login_form_login_success(self, message: LoginForm.LoginSuccess) -> None:
        self.notify('push do blpfs')


    def on_register_form_register_success(self, message: RegisterForm.RegisterSuccess) -> None:
        tabs = self.query_one('#tabs', Tabs)
        tabs.active = 'login'
        self.active_tab = 'Login'
        self._update_form_visibility()