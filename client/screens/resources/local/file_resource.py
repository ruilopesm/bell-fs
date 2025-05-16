from textual.message import Message
from textual.app import ComposeResult
from textual.widgets import Button, Label
from textual.containers import HorizontalGroup, Horizontal
from screens.resources.utils import conver_textual_id_to_uuid, convert_uuid_to_textual_id


class FileResource(HorizontalGroup):

    class Edit(Message):
        def __init__(self, resource_id: str):
            super().__init__()
            self.resource_id = resource_id

    class Share(Message):
        def __init__(self, resource_id: str):
            super().__init__()    
            self.resource_id = resource_id

    class Delete(Message):
        def __init__(self, resource_id: str):
            super().__init__()
            self.resource_id = resource_id

    def __init__(self, id : str, filename: str):
        super().__init__(id=convert_uuid_to_textual_id(id))
        self.filename = filename

    def compose(self) -> ComposeResult:
        yield Label(self.filename, classes='filename-label')
        with Horizontal(classes="button-group"):
            yield Button('Edit', id='edit', variant='primary', classes='button-of-group')
            yield Button('Share', id='share', variant='primary', classes='button-of-group')
            yield Button('Delete', id='delete', variant='error', classes='button-of-group')

    def on_button_pressed(self, event: Button.Pressed) -> None:
        button_id = event.button.id
        if button_id == 'edit':
            self.post_message(self.Edit(conver_textual_id_to_uuid(self.id)))
        elif button_id == 'share':
            self.post_message(self.Share(conver_textual_id_to_uuid(self.id)))
        elif button_id == 'delete':
            self.post_message(self.Delete(conver_textual_id_to_uuid(self.id)))
