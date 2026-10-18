import shutil


def clear_directory(directory):
    if directory.is_symlink():
        directory.unlink()
        return
    if directory.is_dir():
        shutil.rmtree(directory)


def restore_file(source, destination):
    if not source.is_file():
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    destination.chmod(0o644)
