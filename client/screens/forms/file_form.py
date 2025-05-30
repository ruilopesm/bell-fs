from textual.reactive import reactive
from textual.screen import Screen
from textual.app import ComposeResult
from textual.containers import Horizontal
from api.decorators import safe_api_callback
from textual.widgets import Button, DirectoryTree, Select


class FileForm(Screen[str]):

    current_filename = reactive(None)

    def compose(self) -> ComposeResult:
        self.directory_tree = DirectoryTree('./', id='file-explorer')
        self.add_btn = Button('Add File', id='addFileButton', variant='primary')
        self.cancel_btn = Button('Cancel', id='cancelFileButton', variant='error')
        yield self.directory_tree
        yield Select(id='compartment-select', prompt='Compartment', options=[])
        yield Select(id='confidentialiy-select', prompt='Confidentiality level', options=[])
        yield Select( id='integrity-select', prompt='Integrity level', options=[])
        with Horizontal():
            yield self.add_btn
            yield self.cancel_btn

    async def on_mount(self) -> None:
        self.run_worker(self.load_selects(), exclusive=True)

    def on_directory_tree_file_selected(self, message: DirectoryTree.FileSelected) -> None:
        self.current_filename = str(message.path)
        self.notify(self.current_filename, title='Selected File')

    async def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'addFileButton':
            self.run_worker(self.handle_add_file(), exclusive=True)
        elif event.button.id == 'cancelFileButton':
            self.dismiss('')

    @safe_api_callback('Set Selectors Failed')
    async def load_selects(self) -> None:
        levels_response = await self.app.api.list_levels()
        compartments_response = await self.app.api.list_compartments()

        compartments = compartments_response.json().get('compartments', [])
        confidentialities = levels_response.json().get('confidentialities', [])
        integrities = levels_response.json().get('integrities', [])

        compartment_select = self.query_one('#compartment-select', Select)
        confidentiality_select = self.query_one('#confidentialiy-select', Select)
        integrity_select = self.query_one('#integrity-select', Select)

        confidentiality_select.set_options([(value['name'], value['name']) for value in confidentialities])
        integrity_select.set_options([(value['name'], value['name']) for value in integrities])
        compartment_select.set_options([(value['name'], value['name']) for value in compartments])

    @safe_api_callback('Add file Failed')
    async def handle_add_file(self) -> None:
        compartment_select = self.query_one('#compartment-select', Select)
        confidentiality_select = self.query_one('#confidentialiy-select', Select)
        integrity_select = self.query_one('#integrity-select', Select)

        if self.current_filename == None:
            self.notify('No file has been selected', title='Invalid File', severity='error')

        elif Select.BLANK in [compartment_select.value, confidentiality_select.value, integrity_select.value]:
            self.notify('Check that you have entered all parameters', title='Missing Values', severity='error')

        else:
            with open(self.current_filename, 'rb') as file:
                await self.app.api.create_file(
                    self.current_filename.split('/')[-1],
                    file.read().decode(),
                    compartment_select.value,
                    confidentiality_select.value,
                    integrity_select.value)    
            self.dismiss(self.current_filename)