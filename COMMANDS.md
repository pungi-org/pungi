# Command Reference

Like `git`, the `pungi` command delegates to subcommands based on its
first argument.

The most common subcommands are:

* [`pungi help`](#pungi-help)
* [`pungi commands`](#pungi-commands)
* [`pungi local`](#pungi-local)
* [`pungi global`](#pungi-global)
* [`pungi shell`](#pungi-shell)
* [`pungi install`](#pungi-install)
* [`pungi uninstall`](#pungi-uninstall)
* [`pungi rehash`](#pungi-rehash)
* [`pungi version`](#pungi-version)
* [`pungi versions`](#pungi-versions)
* [`pungi which`](#pungi-which)
* [`pungi whence`](#pungi-whence)
* [`pungi exec`](#pungi-exec)
* [`pungi root`](#pungi-root)
* [`pungi prefix`](#pungi-prefix)
* [`pungi hooks`](#pungi-hooks)
* [`pungi shims`](#pungi-shims)
* [`pungi init`](#pungi-init)
* [`pungi completions`](#pungi-completions)

## `pungi help`

List all available pungi commands along with a brief description of what they do. Run `pungi help <command>` for information on a specific command. For full documentation, see: https://github.com/pungi-org/pungi#readme


## `pungi commands`

Lists all available Pungi commands.


## `pungi local`

Sets a local application-specific Python version by writing the version
name to a `.python-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `PUNGI_VERSION` environment variable or with the `pungi shell`
command.

    $ pungi local 2.7.6

When run without a version number, `pungi local` reports the currently
configured local version. You can also unset the local version:

    $ pungi local --unset

Previous versions of Pungi stored local version specifications in a
file named `.pungi-version`. For backwards compatibility, Pungi will
read a local version specified in an `.pungi-version` file, but a
`.python-version` file in the same directory will take precedence.


### `pungi local` (advanced)

You can specify multiple versions as local Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pungi local 2.7.6 3.3.3
    $ pungi versions
      system
    * 2.7.6 (set by /Users/yyuu/path/to/project/.python-version)
    * 3.3.3 (set by /Users/yyuu/path/to/project/.python-version)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pungi local 3.3.3 2.7.6
    $ pungi versions
      system
    * 2.7.6 (set by /Users/yyuu/path/to/project/.python-version)
    * 3.3.3 (set by /Users/yyuu/path/to/project/.python-version)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


## `pungi global`

Sets the global version of Python to be used in all shells by writing
the version name to the `~/.pungi/version` file. This version can be
overridden by an application-specific `.python-version` file, or by
setting the `PUNGI_VERSION` environment variable.

    $ pungi global 2.7.6

The special version name `system` tells pungi to use the system Python
(detected by searching your `$PATH`).

When run without a version number, `pungi global` reports the
currently configured global version.


### `pungi global` (advanced)

You can specify multiple versions as global Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pungi global 2.7.6 3.3.3
    $ pungi versions
      system
    * 2.7.6 (set by /Users/yyuu/.pungi/version)
    * 3.3.3 (set by /Users/yyuu/.pungi/version)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pungi global 3.3.3 2.7.6
    $ pungi versions
      system
    * 2.7.6 (set by /Users/yyuu/.pungi/version)
    * 3.3.3 (set by /Users/yyuu/.pungi/version)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


## `pungi shell`

Sets a shell-specific Python version by setting the `PUNGI_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ pungi shell pypy-2.2.1

When run without a version number, `pungi shell` reports the current
value of `PUNGI_VERSION`. You can also unset the shell version:

    $ pungi shell --unset

Note that you'll need pungi's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PUNGI_VERSION` variable yourself:

    $ export PUNGI_VERSION=pypy-2.2.1


### `pungi shell` (advanced)

You can specify multiple versions via `PUNGI_VERSION` at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pungi shell 2.7.6 3.3.3
    $ pungi versions
      system
    * 2.7.6 (set by PUNGI_VERSION environment variable)
    * 3.3.3 (set by PUNGI_VERSION environment variable)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pungi shell 3.3.3 2.7.6
    $ pungi versions
      system
    * 2.7.6 (set by PUNGI_VERSION environment variable)
    * 3.3.3 (set by PUNGI_VERSION environment variable)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


## `pungi install`

Install a Python version (using [`python-build`](https://github.com/pyenv/pyenv/tree/master/plugins/python-build)).

    Usage: pungi install [-f] [-kvp] <version>
           pungi install [-f] [-kvp] <definition-file>
           pungi install -l|--list

      -l/--list             List all available versions
      -f/--force            Install even if the version appears to be installed already
      -s/--skip-existing    Skip the installation if the version appears to be installed already

      python-build options:

      -k/--keep        Keep source tree in $PUNGI_BUILD_ROOT after installation
                       (defaults to $PUNGI_ROOT/sources)
      -v/--verbose     Verbose mode: print compilation status to stdout
      -p/--patch       Apply a patch from stdin before building
      -g/--debug       Build a debug version

To list the all available versions of Python, including Anaconda, Jython, pypy, and stackless, use:

    $ pungi install --list

Then install the desired versions:

    $ pungi install 2.7.6
    $ pungi install 2.6.8
    $ pungi versions
      system
      2.6.8
    * 2.7.6 (set by /home/yyuu/.pungi/version)

## `pungi uninstall`

Uninstall a specific Python version.

    Usage: pungi uninstall [-f|--force] <version>

       -f  Attempt to remove the specified version without prompting
           for confirmation. If the version does not exist, do not
           display an error message.


## `pungi rehash`

Installs shims for all Python binaries known to pungi (i.e.,
`~/.pungi/versions/*/bin/*`). Run this command after you install a new
version of Python, or install a package that provides binaries.

    $ pungi rehash


## `pungi version`

Displays the currently active Python version, along with information on
how it was set.

    $ pungi version
    2.7.6 (set by /home/yyuu/.pungi/version)


## `pungi versions`

Lists all Python versions known to pungi, and shows an asterisk next to
the currently active version.

    $ pungi versions
      2.5.6
      2.6.8
    * 2.7.6 (set by /home/yyuu/.pungi/version)
      3.3.3
      jython-2.5.3
      pypy-2.2.1


## `pungi which`

Displays the full path to the executable that pungi will invoke when
you run the given command.

    $ pungi which python3.3
    /home/yyuu/.pungi/versions/3.3.3/bin/python3.3

Use --nosystem argument in case when you don't need to search command in the 
system environment.

## `pungi whence`

Lists all Python versions with the given command installed.

    $ pungi whence 2to3
    2.6.8
    2.7.6
    3.3.3

## `pungi exec`

    Usage: pyenv exec <command> [arg1 arg2...]

Runs an executable by first preparing PATH so that the selected Python
version's `bin` directory is at the front.

For example, if the currently selected Python version is 3.9.7:

    pyenv exec pip install -r requirements.txt
    
is equivalent to:

    PATH="$PYENV_ROOT/versions/3.9.7/bin:$PATH" pip install -r requirements.txt

## `pungi root`

Displays the root directory where versions and shims are kept.

    $ pyenv root
    /home/user/.pyenv

## `pungi prefix`

Displays the directory where a Python version is installed. If no
version is given, `pyenv prefix` displays the location of the
currently selected version.

    $ pyenv prefix 3.9.7
    /home/user/.pyenv/versions/3.9.7

## `pungi hooks`

Lists installed hook scripts for a given pyenv command.

    Usage: pyenv hooks <command>

## `pungi shims`

List existing pyenv shims.

    Usage: pyenv shims [--short]

    $ pyenv shims
    /home/user/.pyenv/shims/2to3
    /home/user/.pyenv/shims/2to3-3.9
    /home/user/.pyenv/shims/idle
    /home/user/.pyenv/shims/idle3
    /home/user/.pyenv/shims/idle3.9
    /home/user/.pyenv/shims/pip
    /home/user/.pyenv/shims/pip3
    /home/user/.pyenv/shims/pip3.9
    /home/user/.pyenv/shims/pydoc
    /home/user/.pyenv/shims/pydoc3
    /home/user/.pyenv/shims/pydoc3.9
    /home/user/.pyenv/shims/python
    /home/user/.pyenv/shims/python3
    /home/user/.pyenv/shims/python3.9
    /home/user/.pyenv/shims/python3.9-config
    /home/user/.pyenv/shims/python3.9-gdb.py
    /home/user/.pyenv/shims/python3-config
    /home/user/.pyenv/shims/python-config

## `pungi init`

Configure the shell environment for pyenv

    Usage: eval "$(pyenv init [-|--path] [--no-rehash] [<shell>])"

      -                    Initialize shims directory, print PYENV_SHELL variable, completions path
                           and shell function
      --path               Print shims path
      --no-rehash          Add no rehash command to output     

## `pungi completions`

Lists available completions for a given pyenv command.

    Usage: pyenv completions <command> [arg1 arg2...]
