import base64
import secrets
import string
from enum import StrEnum


class RandomFormat(StrEnum):
    ASCII = "ascii"
    HEX = "hex"
    BASE64 = "base64"


def generate_random_value(length, random_format=RandomFormat.ASCII):
    if random_format == RandomFormat.HEX:
        return secrets.token_hex(length)
    if random_format == RandomFormat.BASE64:
        return base64.b64encode(secrets.token_bytes(length)).decode("ascii")
    random_string = secrets.choice(string.ascii_letters)
    for _ in range(length - 1):
        random_string += secrets.choice(string.ascii_letters + string.digits)

    return random_string
