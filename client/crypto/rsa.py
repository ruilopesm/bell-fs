from cryptography.hazmat.backends import default_backend  # type: ignore
from cryptography.hazmat.primitives import serialization, hashes  # type: ignore
from cryptography.hazmat.primitives.asymmetric import padding as asym_padding  # type: ignore


def load_private_key(key_path, password=None):
    with open(key_path, 'rb') as f:
        if isinstance(password, str):
            password = password.encode()
        return serialization.load_pem_private_key(f.read(), password=password, backend=default_backend())


def rsa_sign(private_key, message):
    return private_key.sign(
        message,
        asym_padding.PSS(
            mgf=asym_padding.MGF1(hashes.SHA256()),
            salt_length=asym_padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256())


def rsa_verify_signature(signature, ciphertext, public_key) -> bool:
    try:
        public_key.verify(
            signature,
            ciphertext,
            asym_padding.PSS(
                mgf=asym_padding.MGF1(hashes.SHA256()),
                salt_length=asym_padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except:
        return False