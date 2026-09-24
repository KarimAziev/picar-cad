"""Shared configuration and checked log parsing for OpenSCAD tests."""

import os
import re

OPENSCAD = os.environ.get("OPENSCAD", "openscad")


def echo_value(log: str, name: str) -> str:
    """Read a named echo, reporting the complete log if it is missing."""
    match = re.search(rf"^ECHO: {re.escape(name)} = (.*)$", log, re.MULTILINE)
    assert match is not None, f"Missing OpenSCAD echo {name!r}:\n{log}"
    return match[1]
