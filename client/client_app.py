from textual.app import App, ComposeResult
from textual.widgets import Footer
from screens.auth import Auth
from api.client import AsyncAPIClient


class ClientApp(App):

    def __init__(self, api : AsyncAPIClient) -> None:
        super().__init__()
        self.api = api

    def compose(self) -> ComposeResult:
        yield Footer()

    def on_mount(self):
        self.push_screen(Auth())