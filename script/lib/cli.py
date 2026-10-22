import sys


def help_requested():
    arguments = sys.argv[1:]
    if "--" in arguments:
        arguments = arguments[: arguments.index("--")]

    return "-h" in arguments or "--help" in arguments
