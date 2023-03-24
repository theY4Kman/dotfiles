def __initialize_custom_keybindings():
    from IPython import InteractiveShell
    from prompt_toolkit import VERSION as PTK_VERSION
    from prompt_toolkit.application.current import get_app
    from prompt_toolkit.filters import (
        Condition,
        emacs_insert_mode,
        in_paste_mode,
        vi_insert_mode,
    )
    from prompt_toolkit.key_binding.bindings.named_commands import get_by_name, register
    from prompt_toolkit.key_binding.key_bindings import KeyBindings
    from prompt_toolkit.key_binding.key_processor import KeyPressEvent


    IS_PTK2 = IS_PTK3 = False
    PTK_VERSION = tuple(str(p) for p in PTK_VERSION)

    if ('3',) <= PTK_VERSION < ('4',):
        IS_PTK3 = True
    elif ('2',) <= PTK_VERSION < ('3',):
        IS_PTK2 = True

    ipython: InteractiveShell = get_ipython()


    E = KeyPressEvent

    @register('insert-line-above')
    def _(event: E) -> None:
        """
        Newline, before current (in case of multiline input)
        """
        event.current_buffer.insert_line_above(copy_margin=not in_paste_mode())

    @register('insert-line-below')
    def _(event: E) -> None:
        """
        Newline, after current (in case of multiline input)
        """
        event.current_buffer.insert_line_below(copy_margin=not in_paste_mode())

    @register('accept-buffer')
    def _(event: E) -> None:
        """
        Execute the current buffer
        """
        event.current_buffer.validate_and_handle()

    insert_mode = vi_insert_mode | emacs_insert_mode

    @Condition
    def has_text_before_cursor() -> bool:
        return bool(get_app().current_buffer.text)

    kb: KeyBindings = ipython.pt_app.key_bindings

    kb.add('c-backspace')(
        get_by_name('backward-kill-word'))

    kb.add('c-enter', filter=insert_mode)(
        get_by_name('insert-line-above'))
    kb.add('s-enter', filter=insert_mode)(
        get_by_name('insert-line-below'))

    kb.add('c-s-enter')(
        get_by_name('accept-buffer'))

    if IS_PTK2:
        @register("beginning-of-buffer")
        def beginning_of_buffer(event: E) -> None:
            """
            Move to the start of the buffer.
            """
            buff = event.current_buffer
            buff.cursor_position = 0

        @register("end-of-buffer")
        def end_of_buffer(event: E) -> None:
            """
            Move to the end of the buffer.
            """
            buff = event.current_buffer
            buff.cursor_position = len(buff.text)

        # Don't add c-home and c-end input sequences into the buffer
        @kb.add('c-home')
        @kb.add('c-end')
        def _(event: E) -> None:
            pass

        kb.add('c-home')(get_by_name('beginning-of-buffer'))
        kb.add('c-end')(get_by_name('end-of-buffer'))


__initialize_custom_keybindings()
del __initialize_custom_keybindings

# noinspection PyStatementEffect
None  # hide output from ipython
