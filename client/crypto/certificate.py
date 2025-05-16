import base64
import datetime
from cryptography import x509 # type: ignore
from cryptography.hazmat.primitives import serialization # type: ignore


def certificate_load(path):
    with open(path, 'rb') as file:
        certificate = x509.load_pem_x509_certificate(file.read())
    return certificate


def certificate_validtime(cert):
    now = datetime.datetime.now(tz=datetime.timezone.utc)
    if not(cert.not_valid_before_utc <= now <= cert.not_valid_after_utc):
        raise x509.verification.VerificationError(
            'Certificate is not valid at this time')


def certifica_validON(cert, cn):
    if cn != cert.subject.get_attributes_for_oid(x509.NameOID.ORGANIZATION_NAME)[0].value:
        raise x509.verification.VerificationError(
            'Certificate extensions does not match ORGANIZATION_NAME')


def certificate_validSignature(user_cert, ca_cert):
    ca_public_key = ca_cert.public_key()
    ca_public_key.verify(
        user_cert.signature,
        user_cert.tbs_certificate_bytes,
    )


def serialize_ceritifcate_to_base64(cert):
    data_bytes = cert.public_bytes(encoding=serialization.Encoding.PEM)
    return base64.b64encode(data_bytes).decode('utf-8')


def deserialize_certificate_from_base64(cert_base64):
    return x509.load_pem_x509_certificate(base64.b64decode(cert_base64.encode('utf-8')))