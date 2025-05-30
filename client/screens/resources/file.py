from textual.message import Message
from textual.app import ComposeResult
from textual.widgets import Button, Label
from textual.containers import HorizontalGroup, Horizontal
from screens.resources.utils import conver_textual_id_to_uuid, convert_uuid_to_textual_id


class File(HorizontalGroup):

    class Read(Message):
        def __init__(self, resource_id: str):
            super().__init__()
            self.resource_id = resource_id

    class Write(Message):
        def __init__(self, resource_id: str):
            super().__init__()    
            self.resource_id = resource_id

    class Manage(Message):
        def __init__(self, resource_id: str):
            super().__init__()    
            self.resource_id = resource_id

    class Delete(Message):
        def __init__(self, resource_id: str):
            super().__init__()
            self.resource_id = resource_id

    def __init__(self, file_data: dict):
        super().__init__(id=convert_uuid_to_textual_id(file_data['id']))
        self.file_data = file_data 

    def compose(self) -> ComposeResult:
        yield Label(self.file_data['compartment']['name'], classes='text-label')
        yield Label(self.file_data['name'], classes='text-label')
        with Horizontal(classes='button-group'):
            yield Button('Read', id='read', variant='primary', classes='button-of-group', disabled=(not self.file_data['permissions']['read']))
            yield Button('Write', id='write', variant='primary', classes='button-of-group', disabled=(not self.file_data['permissions']['update']))
            yield Button('Manage', id='manage', variant='primary', classes='button-of-group', disabled=(not self.file_data['permissions']['manage']))
            yield Button('Delete', id='delete', variant='error', classes='button-of-group', disabled=(not self.file_data['permissions']['delete']))

    def on_button_pressed(self, event: Button.Pressed) -> None:
        button_id = event.button.id
        if button_id == 'read':
            self.post_message(self.Read(conver_textual_id_to_uuid(self.id)))
        elif button_id == 'write':
            self.post_message(self.Write(conver_textual_id_to_uuid(self.id)))
        elif button_id == 'manage':
            self.post_message(self.Manage(conver_textual_id_to_uuid(self.id)))
        elif button_id == 'delete':
            self.post_message(self.Delete(conver_textual_id_to_uuid(self.id)))