---
default_highlighter: oil-sh
---

Oil's Headless Mode: For Alternative UIs
========================================

A GUI or [TUI][] process can start Oil like this:

    osh --headless

and send messages to it over a Unix domain socket.  In this mode, the language
and shell state are **decoupled** from the user interface.

This is a unique feature that other shells don't have!

[TUI]: https://en.wikipedia.org/wiki/Text-based_user_interface

Note: This doc is **in progress**.  Join the `#shell-gui` channel on
[Zulip]($xref:zulip) for current information.

<div id="toc">
</div>

## The General Idea

The UI process should handle these things:

- Auto-completion.  It should use Oil for parsing, and not try to parse shell
  itself!
- History: Allow the user to retrieve commands typed in the past.
- Cancelling commands in progress.
- Optional: multiplexing among multiple headless shells.

The shell process handles these things:

- Parsing and evaluating the language
- Maintaining state (shell options, variables, etc.)

## How to Write a Client for a Headless Shell

### Implement the FANOS Protocol

FANOS stands for *File descriptors and Netstrings Over Sockets*.  It's a
**control** protocol that already has 2 implementations, which are very small:

- [client/py_fanos.py]($oil-src): 102 lines of code
- [native/fanos.c]($oil-src): 294 lines of code

### Send Commands and File Descriptors to the "Server"

List of commands:

- `ECMD`.  Parse and evaluate an "entered command".  The logic is similar to
  the `eval` and `source` builtins.
  - The stdin, stdout, and stderr of **the shell and its child processes** will
    be redirected to the descriptors you pass.
  - There's no history expansion for now.  The UI can implement this itself,
    and Oil may be able to help.

TODO: More commands.

### Query Shell State and Render it in the UI

You may want to use commands like these to draw the UI:

- `echo ${PS1@P}` -- render the prompt
- `echo $PWD $_` -- get the current directory and current status

You can redirect them to a pipe, rather than displaying them in the terminal.

Remember that a fundamental difference between a REPL and a GUI is that a GUI
**shows state** explicitly.  This is a good thing and you should take advantage
of it!

### Example Code

See [client/headless_demo.py]($oil-src).  This is pure Python code that's
divorced from the rest of Oil.

## Related Links

Feel free to edit these pages:

- [Headless Mode][] on the wiki.  We want there to be a rich ecosystem of
  interactive shells built upon Oil.
- [Interactive Shell][] on the wiki.  Be inspired by these nice projects, many
  of which have screenshots! 

[Headless Mode]: https://github.com/oilshell/oil/wiki/Headless-Mode

[Interactive Shell]: https://github.com/oilshell/oil/wiki/Interactive-Shell