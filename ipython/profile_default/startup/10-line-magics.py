def __initialize_custom_line_magics():
    import subprocess
    import sys
    from functools import wraps

    from IPython.core.magic import needs_local_scope, register_line_magic

    def register_value_magic(fn):
        @register_line_magic
        @needs_local_scope
        @wraps(fn)
        def wrapper(line, local_ns):
            if not line.strip():
                line = '_'
            value = eval(line, globals(), local_ns)
            return fn(value)
        return wrapper

    @register_value_magic
    def v(value):
        if hasattr(value, '__dict__'):
            return value.__dict__
        elif hasattr(value, '__slots__'):
            from itertools import chain
            slots = chain.from_iterable(getattr(cls, '__slots__', ())
                                        for cls in type(value).__mro__)
            return {k: getattr(value, k, None) for k in slots}
        else:
            return None

    @register_value_magic
    def p(value):
        """Print a value, or last result if none specified"""
        return print(value)

    @register_value_magic
    def l(value):
        """Create a list from a value, or last result if none specified"""
        return list(value)

    @register_value_magic
    def t(value):
        """Create a tuple from a value, or last result if none specified"""
        return tuple(value)

    @register_value_magic
    def s(value):
        """Create a set from a value, or last result if none specified"""
        return set(value)

    @register_value_magic
    def d(value):
        """Create a dict from a value, or last result if none specified"""
        return dict(value)

    def xclip_copy(text: str) -> None:
        subprocess.run(
            ['xclip', '-selection', 'clipboard'],
            input=text,
            encoding='utf-8',
        )

    @register_value_magic
    def copy(value):
        """Copy a value's str() to clipboard, or last result's str() if none specified"""
        text = str(value)
        try:
            xclip_copy(text)
        except Exception as e:
            print(f'Error copying to clipboard! {e}', file=sys.stderr)
        else:
            chars_copied = len(text)
            plural = '' if chars_copied == 1 else 's'
            print(f'Copied {chars_copied} character{plural} to clipboard!')


__initialize_custom_line_magics()
del __initialize_custom_line_magics
None  # hide output from ipython
