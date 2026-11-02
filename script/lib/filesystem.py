import shutil


def clear_directory(directory):
    if directory.is_symlink() or not directory.is_dir():
        return

    for entry in directory.iterdir():
        if entry.is_symlink() or not entry.is_dir():
            entry.unlink()
        else:
            shutil.rmtree(entry)


def restore_file(source, destination):
    if not source.is_file():
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    destination.chmod(0o644)


def find_named_files(directory, suffix):
    named_files = {}
    for path in sorted(directory.glob(f"*{suffix}")):
        named_files[path.name.removesuffix(suffix)] = path

    return named_files
