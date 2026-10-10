import re


def sanitize_name(name):
    return re.sub(r"[^a-zA-Z0-9_-]+", "-", name)
