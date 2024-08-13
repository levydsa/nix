
### XDG Compliant History File

import atexit
import os
import sys
from pathlib import Path
import readline

if hasattr(sys, '__interactivehook__'):
    del sys.__interactivehook__

data_home_path = Path(os.getenv('XDG_DATA_HOME', '~/.local/share'))
history = data_home_path / 'python_history'

try:
    history.touch()
except FileNotFoundError:
    history.parent.mkdir(parents=True)

readline.parse_and_bind("tab: complete")
readline.read_history_file(history)
readline.set_history_length(5000)

atexit.register(readline.write_history_file, history)

