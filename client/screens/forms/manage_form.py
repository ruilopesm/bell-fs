from textual.reactive import reactive
from textual.screen import Screen
from textual.app import ComposeResult
from api.decorators import safe_api_callback
from textual.widgets import Button, Select
from textual.containers import Horizontal


class ManageForm(Screen[dict]):

    def compose(self) -> ComposeResult:
        self.add_btn = Button('Update Attributes', id='saveManageButton', variant='primary')
        self.cancel_btn = Button('Cancel', id='cancelManageButton', variant='error')
        yield Select(id='confidentialiy-select', prompt='Confidentiality level', options=[])
        yield Select(id='integrity-select', prompt='Integrity level', options=[])
        with Horizontal():
            yield self.add_btn
            yield self.cancel_btn

    async def on_mount(self) -> None:
        self.run_worker(self.load_selects(), exclusive=True)

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == 'saveManageButton':
            self.handle_update_file()
        elif event.button.id == 'cancelManageButton':
            self.dismiss({'success': False})

    def handle_update_file(self) -> None:
        confidentiality_select = self.query_one('#confidentialiy-select', Select)
        integrity_select = self.query_one('#integrity-select', Select)

        if Select.BLANK in [confidentiality_select.value, integrity_select.value]:
            self.notify('Check that you have entered all parameters', title='Missing Values', severity='error')

        else:
            self.dismiss({
                'success': True,
                'confidentiality': confidentiality_select.value,
                'integrity': integrity_select.value,
            })

    @safe_api_callback('Set Selectors Failed')
    async def load_selects(self) -> None:
        levels_response = await self.app.api.list_levels()

        confidentialities = levels_response.json().get('confidentialities', [])
        integrities = levels_response.json().get('integrities', [])

        confidentiality_select = self.query_one('#confidentialiy-select', Select)
        integrity_select = self.query_one('#integrity-select', Select)

        confidentiality_select.set_options([(value['name'], value['name']) for value in confidentialities])
        integrity_select.set_options([(value['name'], value['name']) for value in integrities])