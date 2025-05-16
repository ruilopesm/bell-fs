from textual.reactive import reactive
from textual.screen import Screen
from textual.app import ComposeResult
from textual.widgets import Button, Input
from textual.containers import Horizontal


class DirectoryForm(Screen[str]):

    current_directory = reactive(None)


    def compose(self) -> ComposeResult:
        self.directory = Input(placeholder='Name', classes='directory-form-input')
        self.add_btn = Button('Add Directory', id='addDirectoryButton', variant='primary')
        self.cancel_btn = Button('Cancel', id='cancelDirectoryButton', variant='error')
        yield self.directory
        with Horizontal():
            yield self.add_btn
            yield self.cancel_btn


    def _check_directory(self) -> bool:
        return self.current_directory != None and len(self.current_directory) > 0


    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'addDirectoryButton':
            self.current_directory = self.directory.value
            if self._check_directory():
                self.dismiss(self.current_directory)
            else:
                self.notify('The selected directory is not valid', title='Invalid directory', severity='error')
        elif event.button.id == 'cancelDirectoryButton':
            self.dismiss()