from textual.message import Message
from textual.app import ComposeResult
from textual.widgets import Button, Label
from textual.containers import HorizontalGroup, Horizontal
from screens.resources.utils import conver_textual_id_to_uuid, convert_uuid_to_textual_id


class FileSharedResource(HorizontalGroup):

    class Read(Message):
        def __init__(self, resource_id: str, owner: str):
            super().__init__()
            self.owner = owner
            self.resource_id = resource_id

    class Write(Message):
        def __init__(self, resource_id: str, owner: str):
            super().__init__()
            self.owner = owner
            self.resource_id = resource_id

    class Append(Message):
        def __init__(self, resource_id: str, owner: str):
            super().__init__()
            self.owner = owner
            self.resource_id = resource_id

    def __init__(self, id : str, filename: str, permissions: list, owner: str):
        super().__init__(id=convert_uuid_to_textual_id(id))
        self.owner = owner
        self.filename = filename
        self.permissions = permissions

    def compose(self) -> ComposeResult:
        yield Label(self.owner, classes='filename-label')
        yield Label(self.filename, classes='filename-label')
        with Horizontal(classes="button-group"):
            yield Button('Read', id='read', variant='primary', disabled=(not self.permissions['read']), classes='button-of-group')
            yield Button('Write', id='write', variant='primary', disabled=(not self.permissions['write']), classes='button-of-group')
            yield Button('Append', id='append', variant='primary', disabled=(not self.permissions['append']), classes='button-of-group')

    def on_button_pressed(self, event: Button.Pressed) -> None:
        button_id = event.button.id
        if button_id == 'read':
            self.post_message(self.Read(conver_textual_id_to_uuid(self.id), self.owner))
        elif button_id == 'write':
            self.post_message(self.Write(conver_textual_id_to_uuid(self.id), self.owner))
        elif button_id == 'append':
            self.post_message(self.Append(conver_textual_id_to_uuid(self.id), self.owner))