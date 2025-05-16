from rich.syntax import Syntax
from textual.app import ComposeResult
from textual.containers import ScrollableContainer
from textual.screen import ModalScreen
from textual.widgets import Static


class ViewerScreen(ModalScreen):
    DEFAULT_CSS = '''
    ViewerScreen {
        #code {
            border: heavy $accent;
            margin: 2 4;
            scrollbar-gutter: stable;
            Static {
                width: auto;
            }
        }
    }
    '''
    BINDINGS = [('escape', 'dismiss', 'Dismiss code')]

    def __init__(self, title: str, code: str) -> None:
        super().__init__()
        self.code = code
        self.title = title

    def compose(self) -> ComposeResult:
        with ScrollableContainer(id='code'):
            yield Static(
                Syntax(
                    self.code, lexer='python', indent_guides=True, line_numbers=True
                ),
                expand=True,
            )

    def on_mount(self):
        code_widget = self.query_one('#code')
        code_widget.border_title = self.title
        code_widget.border_subtitle = 'Escape to close'