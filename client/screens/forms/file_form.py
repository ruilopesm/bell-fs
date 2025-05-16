from textual.reactive import reactive
from textual.screen import Screen
from textual.app import ComposeResult
from textual.widgets import Button, DirectoryTree
from textual.containers import Horizontal


class FileForm(Screen[str]):

    current_filename = reactive(None)

    def compose(self) -> ComposeResult:
        self.directory_tree = DirectoryTree('./', id='file-explorer')
        self.add_btn = Button('Add File', id='addFileButton', variant='primary')
        self.cancel_btn = Button('Cancel', id='cancelFileButton', variant='error')
        yield self.directory_tree
        with Horizontal():
            yield self.add_btn
            yield self.cancel_btn

    def on_directory_tree_file_selected(self, message: DirectoryTree.FileSelected) -> None:
        self.current_filename = str(message.path)
        self.notify(self.current_filename, title='Selected file')

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'addFileButton':
            if self.current_filename != None:
                self.dismiss(self.current_filename)
            else:
                self.notify('No file has been selected', title='Invalid file', severity='error')
        elif event.button.id == 'cancelFileButton':
            self.dismiss()