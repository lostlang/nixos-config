import hashlib
import os
import re
from pathlib import Path

from .identifiers import sanitize_name


def is_project_session(session):
    return bool(
        re.fullmatch(r"[a-zA-Z0-9_-]+-[a-zA-Z0-9_-]{1,40}-[0-9a-f]{12}", session)
    )


def project_session_name(layout, project_dir):
    layout_name = sanitize_name(Path(layout).stem)
    project_name = sanitize_name(Path(project_dir).name or "/")
    project_hash = hashlib.sha256(os.fsencode(project_dir)).hexdigest()[:12]

    return f"{layout_name}-{project_name[:40]}-{project_hash}"
