---
in_progress: yes
---

Examples of HTML Plugins
========================

This file is essentially a unit test for [doctools/oil_doc.py]($oil-src), which
contains all the HTML plugins.

Related: [How We Build Oil's Documentation](doc-toolchain.html).

<div id="toc">
</div>

## Link Shortcuts with `$`

- `$xref`: [bash]($xref)
- `$blog-tag`: [oil-release]($blog-tag)
- `$oil-src`: [INSTALL.txt]($oil-src), [INSTALL.txt]($oil-src:INSTALL.txt)
- `$blog-code-src`: [interactive-shell/README.md]($blog-code-src)
- `$issue`: [issue 11]($issue:11)
- `$oil-commit`: [this commit]($oil-commit:a1dad10d53b1fb94a164888d9ec277249ae98b58)

## Syntax Highlighting Specified In Front matter

If every `pre` block in a document needs the same higlighter, you can specify
it in the front matter like this:

    ---
    default_highlighter: oil-sh
    ---

    My Title
    ========

## Syntax Highlighting With Fenced Code Blocks

### sh-prompt 

Highlights the `$` line.  For example, this input

    ```sh-prompt
    $ echo hi   # comment
    hi
    ```

produces

```sh-prompt
$ echo hi   # comment
hi
```

### oil-sh

A generic formatter that works for both shell and Oil code.  It's used in
[idioms.html](idioms.html), [known differences](known-differences.html), and is
now the default for the Oil blog.

(Detail: it's the same as `sh-prompt` for now.  We might want to do something
smarter.)

### none (Explicit Override)

To override the default highlighter with none:

    ```none
    $ echo 'no syntax highlighting'
    ```

Result:

```none
$ echo 'no syntax highlighting'
```

### Pygments Lexers

Use any pygments lexer:

    ```python
    x = 42
    print(x, file=sys.stderr)
    ```

produces

```python
x = 42
print(x, file=sys.stderr)
```

### Plugins We Should Have

- oil and osh.  *A Tour of Oil* could use it to show which code blocks can be
  extracted and run.
- Side-by-side sh and Oil
- Side-by-side PCRE and Eggex
- sh-session - How to replace the data?

A shell session could look like this:

    ```session-bash
    $ echo one
    one

    $ for x in foo bar; do
    >   echo $x
    > done
    foo
    bar
    ```

or

    ```session-oil
    $ echo one
    one

    $ for x in foo bar {
    >   echo $x
    > }
    foo
    bar
    ```

<!--
Workflow:
- You should write this directly in Markdown.  Even the output.  So you know
  what you expect.
- Syntax highlighter:
  - $ and > lines prefixes in bold, with the code in blue
  - the rest of the output in black
- Verifier
  - Will extract:
    1. sequences of lines that begin with $ and continue with >
    2. expected output (not beginning with $ or >)
  - It will run those in a CLEAN working directory, one after the other
    - maybe it inserts 'echo __MAGIC_DELIMITER__ between them?
    - Or you could use the headless shell!  To preserve state!
- And then it will diff the actual output vs. the expected output

Another idea: PS2 should lead with the same number of spaces as PS1:

oil$ for x in foo bar {
   .   echo $x
   . }
foo
bar

This looks cleaner.
-->

Embeddings:

- Embed Image Preview of Web Page?
- Embed Github Commit?
  - hashdiv has this for stories
- Graphviz
  - LaTeX (although I don't really use it)

