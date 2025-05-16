from rich.syntax import Syntax
from textual.app import ComposeResult
from textual.containers import ScrollableContainer
from textual.screen import ModalScreen
from textual.widgets import Static, TextArea


class EditorScreen(ModalScreen[str]):
    DEFAULT_CSS = '''
    EditorScreen {
        #code {
            border: heavy $accent;
            margin: 2 5;

            padding: 0;
            TextArea {
                margin: 0;
                width: 100%;
            }
        }
    }
    '''
    BINDINGS = [('escape', 'escape_code_screen', 'Dismiss code')]

    def __init__(self, title: str, code: str) -> None:
        super().__init__()
        self.code = code
        self.title = title

    def compose(self) -> ComposeResult:
        with ScrollableContainer(id='code'):
            yield TextArea.code_editor(self.code, language='python', id='editor')

    def on_mount(self):
        editor = self.query_one('#code')
        editor.border_title = self.title
        editor.border_subtitle = 'Escape to close'

    def action_escape_code_screen(self) -> None:
        editor = self.query_one('#editor')
        self.dismiss(editor.text)