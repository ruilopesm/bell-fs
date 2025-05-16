def convert_uuid_to_textual_id(uuid : str) -> str:
    return '_' + uuid

def conver_textual_id_to_uuid(textual_id : str) -> str:
    return textual_id[1:]