"""
This ipython config file installs a few extra prompt key bindings for a more
familiar editing interface. In particular, it adds support for:

    - Ctrl+Home:
        move to the beginning of the buffer

    - Ctrl+End:
        move to the end of the buffer

    - Ctrl+Backspace:
        delete the last word (only in supporting terminals, i.e. all modern terminals)

For weird, customized terminals like mine, a few additional bindings are supported:

    - Ctrl+Enter (bound to F34):
      Shift+Enter (bound to F35):
        add a newline before the current line

    - Ctrl+Shift+Enter (bound to F36):
        execute the current buffer (alias of Esc, Enter)

"""

from enum import Enum
from itertools import chain

import prompt_toolkit
from prompt_toolkit import keys, application, VERSION as PTK_VERSION
from prompt_toolkit.input import ansi_escape_sequences, vt100_parser
from prompt_toolkit.key_binding import key_bindings, key_processor


IS_PTK2 = IS_PTK3 = False

if ('3',) <= PTK_VERSION < ('4',):
    IS_PTK3 = True
elif ('2',) <= PTK_VERSION < ('3',):
    IS_PTK2 = True


def install_prompt_customizations() -> None:
    if hasattr(prompt_toolkit, 'READLINE_CUSTOMIZATIONS_INSTALLED'):
        # Already installed
        return

    class StrEnum(str, Enum):
        pass


    class ExtraKeys(str, Enum):
        value: str

        ControlBackspace = 'c-backspace'

        ControlEnter = 'c-enter'
        ShiftEnter = 's-enter'
        ControlShiftEnter = 'c-s-enter'


    if IS_PTK3:
        Keys = StrEnum('Keys', [(a.name, a.value) for a in chain(keys.Keys, ExtraKeys)], module='ipython_config')
        Keys.__bases__ += (keys.Keys,)

        keys.Keys = \
            key_bindings.Keys = \
            application.Keys = \
            vt100_parser.Keys = \
            Keys

        def calculate_ALL_KEYS():
            return [k.value for k in Keys]

        keys.ALL_KEYS = key_bindings.ALL_KEYS = calculate_ALL_KEYS()

    elif IS_PTK2:
        Keys = keys.Keys

        Keys.ControlHome = 'c-home'
        Keys.ControlEnd = 'c-end'

        for key in ExtraKeys:
            setattr(Keys, key.name, key.value)

        def calculate_ALL_KEYS():
            return [getattr(Keys, k) for k in dir(Keys) if not k.startswith('_')]

        keys.ALL_KEYS = key_bindings.ALL_KEYS = key_processor.ALL_KEYS = calculate_ALL_KEYS()

    else:
        # We only support v2 and v3
        return


    ansi_escape_sequences.ANSI_SEQUENCES.update({
        '\x08': Keys.ControlBackspace,     # Control-H (8) (Identical to '\b')
        '\x1b[1;5H': Keys.ControlHome,
        '\x1b[1;5F': Keys.ControlEnd,
        '\x1b[21;5~': Keys.ControlEnter,        # F34
        '\x1b[23;5~': Keys.ShiftEnter,          # F35
        '\x1b[24;5~': Keys.ControlShiftEnter,   # F36
    })

    ansi_escape_sequences.REVERSE_ANSI_SEQUENCES.clear()
    ansi_escape_sequences.REVERSE_ANSI_SEQUENCES.update(ansi_escape_sequences._get_reverse_ansi_sequences())

    # Mark ourselves as installed, so as to avoid double-initialization
    prompt_toolkit.READLINE_CUSTOMIZATIONS_INSTALLED = True


install_prompt_customizations()
