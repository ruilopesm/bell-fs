from textual.reactive import reactive
from textual.screen import Screen
from textual.app import ComposeResult
from textual.widgets import Button, DirectoryTree, Select
from textual.containers import Horizontal


class ManageForm(Screen[str]):

    def compose(self) -> ComposeResult:
        self.add_btn = Button('Add File', id='saveManageButton', variant='primary')
        self.cancel_btn = Button('Cancel', id='cancelManageButton', variant='error')
        yield Select(
            id='confidentialiy-select',
            prompt='Confidentiality level',
            options=[(confidentiality, confidentiality) for confidentiality in ['unclassified', 'classified', 'secret', 'top-secret']])
        yield Select(
            id='integrity-select',
            prompt='Integrity level',
            options=[(integrity, integrity) for integrity in ['weak', 'medium', 'strong']])
        with Horizontal():
            yield self.add_btn
            yield self.cancel_btn

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'saveManageButton':
            if self.current_filename != None:
                self.dismiss(self.current_filename)
            else:
                self.notify('No file has been selected', title='Invalid file', severity='error')
        elif event.button.id == 'cancelManageButton':
            self.dismiss()