# Simple Python Version Management: pungi

[![Join the chat at https://gitter.im/yyuu/pyenv](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/yyuu/pyenv?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/pungi/pungi.svg?branch=master)](https://travis-ci.org/pungi/pungi)

pungi lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/rbenv/rbenv) and
[ruby-build](https://github.com/rbenv/ruby-build), and modified for Python.

![Terminal output example](/terminal_output.png)


### pungi _does..._

* Let you **change the global Python version** on a per-user basis.
* Provide support for **per-project Python versions**.
* Allow you to **override the Python version** with an environment
  variable.
* Search commands from **multiple versions of Python at a time**.
  This may be helpful to test across Python versions with [tox](https://pypi.python.org/pypi/tox).


### In contrast with pythonbrew and pythonz, pungi _does not..._

* **Depend on Python itself.** pungi was made from pure shell scripts.
    There is no bootstrap problem of Python.
* **Need to be loaded into your shell.** Instead, pungi's shim
    approach works by adding a directory to your `$PATH`.
* **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv)
    yourself, or [pungi-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
    to automate the process.


----


## Table of Contents

* **[How It Works](#how-it-works)**
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Python Version](#choosing-the-python-version)
  * [Locating the Python Installation](#locating-the-python-installation)
* **[Installation](#installation)**
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
    * [Homebrew on macOS](#homebrew-on-macos)
    * [Advanced Configuration](#advanced-configuration)
    * [Uninstalling Python Versions](#uninstalling-python-versions)
* **[Command Reference](#command-reference)**
* **[Development](#development)**
  * [Version History](#version-history)
  * [License](#license)


----


## How It Works

At a high level, pungi intercepts Python commands using shim
executables injected into your `PATH`, determines which Python version
has been specified by your application, and passes your commands along
to the correct Python installation.

### Understanding PATH

When you run a command like `python` or `pip`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

pungi works by inserting a directory of _shims_ at the front of your
`PATH`:

    $(pungi root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, pungi maintains shims in that
directory to match every Python command across every installed version
of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along
to pungi. So with pungi installed, when you run, say, `pip`, your
operating system will do the following:

* Search your `PATH` for an executable file named `pip`
* Find the pungi shim named `pip` at the beginning of your `PATH`
* Run the shim named `pip`, which in turn passes the command along to
  pungi

### Choosing the Python Version

When you execute a shim, pungi determines which Python version to use by
reading it from the following sources, in this order:

1. The `PUNGI_VERSION` environment variable (if specified). You can use
   the [`pungi shell`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pungi-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.python-version` file in the current
   directory (if present). You can modify the current directory's
   `.python-version` file with the [`pungi local`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pungi-local)
   command.

3. The first `.python-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `$(pungi root)/version` file. You can modify this file using
   the [`pungi global`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pungi-global) command. If the global version
   file is not present, pungi assumes you want to use the "system"
   Python. (In other words, whatever version would run if pungi weren't in your
   `PATH`.)

**NOTE:** You can activate multiple versions at the same time, including multiple
versions of Python2 or Python3 simultaneously. This allows for parallel usage of
Python2 and Python3, and is required with tools like `tox`. For example, to set
your path to first use your `system` Python and Python3 (set to 2.7.9 and 3.4.2
in this example), but also have Python 3.3.6, 3.2, and 2.5 available on your
`PATH`, one would first `pungi install` the missing versions, then set `pungi
global system 3.3.6 3.2 2.5`. At this point, one should be able to find the full
executable path to each of these using `pungi which`, e.g. `pungi which python2.5`
(should display `$(pungi root)/versions/2.5/bin/python2.5`), or `pungi which
python3.4` (should display path to system Python3). You can also specify multiple
versions in a `.python-version` file, separated by newlines.
Lines starting with a `#` are ignored.

### Locating the Python Installation

Once pungi has determined which version of Python your application has
specified, it passes the command along to the corresponding Python
installation.

Each Python version is installed into its own directory under
`$(pungi root)/versions`.

For example, you might have these versions installed:

* `$(pungi root)/versions/2.7.8/`
* `$(pungi root)/versions/3.4.2/`
* `$(pungi root)/versions/pypy-2.4.0/`

As far as Pungi is concerned, version names are simply directories under
`$(pungi root)/versions`.

### Managing Virtual Environments

There is a pungi plugin named [pungi-virtualenv](https://github.com/pyenv/pyenv-virtualenv) which comes with various features to help pungi users to manage virtual environments created by virtualenv or Anaconda.
Because the `activate` script of those virtual environments are relying on mutating `$PATH` variable of user's interactive shell, it will intercept pungi's shim style command execution hooks.
We'd recommend to install pungi-virtualenv as well if you have some plan to play with those virtual environments.


----


## Installation

### Prerequisites:

For pungi to install python correctly you should [**install the Python build dependencies**](https://github.com/pyenv/pyenv/wiki#suggested-build-environment).

### Homebrew on macOS

   1. Consider installing with [Homebrew](https://brew.sh):
      ```sh
      brew update
      brew install pungi
      ```
   2. Then follow the rest of the post-installation steps under [Basic GitHub Checkout](https://github.com/pyenv/pyenv#basic-github-checkout), starting with #2 ("Configure your shell's environment for Pungi").

If you're on Windows, consider using @kirankotari's [`pungi-win`](https://github.com/pungi-win/pungi-win) fork. (Pungi does not work in Windows outside the Windows Subsystem for Linux.)

### The automatic installer

Visit our other project:
https://github.com/pyenv/pyenv-installer


### Basic GitHub Checkout

This will get you going with the latest version of Pungi and make it
easy to fork and contribute any changes back upstream.

1. **Check out Pungi where you want it installed.**
   A good place to choose is `$HOME/.pungi` (but you can install it somewhere else):

        git clone https://github.com/pyenv/pyenv.git ~/.pungi

   Optionally, try to compile a dynamic Bash extension to speed up Pungi. Don't
   worry if it fails; Pungi will still work normally:

        cd ~/.pungi && src/configure && make -C src

2. **Configure your shell's environment for Pungi**

   **Note:** The below instructions for specific shells are designed for common shell setups.  
   If you have an uncommon setup and they don't work for you,
   use the guidance text and the [Advanced Configuration](#advanced-configuration)
   section below to figure out what you need to do in your specific case.
   
   1. **Adjust the session-wide environment for your account.** Define
   the `PUNGI_ROOT` environment variable to point to the path where
   you cloned the Pungi repo, add the `pungi` command-line utility to your `PATH`,
   run the output of `pungi init --path` to enable shims.
   
      These commands need to be added into your shell startup files in such a way
      that _they are executed only once per session, by its login shell._
      This typically means they need to be added into a per-user shell-specific
      `~/.*profile` file, _and_ into `~/.profile`, too, so that they are also
      run by GUI managers (which typically act as a `sh` login shell).

      **MacOS note:** If you installed Pungi with Homebrew, you don't need
      to add the `PUNGI_ROOT=` and `PATH=` lines.
      You also don't need to add commands into `~/.profile` if your shell doesn't use it.
   
      - For **Bash**:

         ~~~ bash
         echo 'export PUNGI_ROOT="$HOME/.pungi"' >> ~/.profile
         echo 'export PATH="$PUNGI_ROOT/bin:$PATH"' >> ~/.profile
         echo 'eval "$(pungi init --path)"' >> ~/.profile
         ~~~

         - **If your `~/.profile` sources `~/.bashrc` (Debian, Ubuntu, Mint):**

            Put these lines into `~/.profile` _before_ the part that sources `~/.bashrc`:
            ~~~bash
            export PUNGI_ROOT="$HOME/.pungi"
            export PATH="$PUNGI_ROOT/bin:$PATH"
            ~~~
            
            And put this line at the _bottom_ of `~/.profile`:
            ~~~bash
            eval "$(pungi init --path)"
            ~~~

            <!--This is an alternative option and needn't be replicated to `pungi init`-->
            Alternatively, for an automated installation, you can run the following:
            ~~~ bash
            echo -e 'if shopt -q login_shell; then' \
                  '\n  export PUNGI_ROOT="$HOME/.pungi"' \
                  '\n  export PATH="$PUNGI_ROOT/bin:$PATH"' \
                  '\n eval "$(pungi init --path)"' \
                  '\nfi' >> ~/.bashrc
            echo -e 'if [ -z "$BASH_VERSION" ]; then'\
                  '\n  export PUNGI_ROOT="$HOME/.pungi"'\
                  '\n  export PATH="$PUNGI_ROOT/bin:$PATH"'\
                  '\n  eval "$(pungi init --path)"'\
                  '\nfi' >>~/.profile
            ~~~

         **Note:** If you have `~/.bash_profile`, make sure that it too executes the above-added commands,
         e.g. by copying them there or by `source`'ing `~/.profile`.

      - For **Zsh**:

         - **MacOS, if Pungi is installed with Homebrew:**

            ~~~ zsh
            echo 'eval "$(pungi init --path)"' >> ~/.zprofile
            ~~~
         
         - **MacOS, if Pungi is installed with a Git checkout:**
         
            ~~~ zsh
            echo 'export PUNGI_ROOT="$HOME/.pungi"' >> ~/.zprofile
            echo 'export PATH="$PUNGI_ROOT/bin:$PATH"' >> ~/.zprofile
            echo 'eval "$(pungi init --path)"' >> ~/.zprofile
            ~~~

         - **Other OSes:**
         
           Same as for Bash above, but add the commands into both `~/.profile`
           and `~/.zprofile`.
        
      - For **Fish shell**:

        Execute this interactively:
        ~~~ fish
        set -Ux PUNGI_ROOT $HOME/.pungi
        set -U fish_user_paths $PUNGI_ROOT/bin $fish_user_paths
        ~~~

        And add this to `~/.config/fish/config.fish`:
        ~~~ fish
        status is-interactive; and pungi init --path | source
        ~~~

        If Fish is not your login shell, also follow the Bash/Zsh instructions to add to `~/.profile`.

      **Proxy note**: If you use a proxy, export `http_proxy` and `https_proxy`, too.

   2. **Add `pungi` into your shell** by running the output of `pungi init -`
     to enable autocompletion and all subcommands.
   
      This command needs to run at startup of any interactive shell instance.
      In an interactive login shell, it needs to run _after_ the commands
      from the previous step.

      - For **bash**:
        ~~~ bash
        echo 'eval "$(pungi init -)"' >> ~/.bashrc
        ~~~
        
        - **If your `/etc/profile` sources `~/.bashrc` (SUSE):**
        
          ~~~bash
          echo 'if command -v pungi >/dev/null; then eval "$(pungi init -)"; fi' >> ~/.bashrc 
          ~~~

      - For **Zsh**:
        ~~~ zsh
        echo 'eval "$(pungi init -)"' >> ~/.zshrc
        ~~~

      - For **Fish shell**:
        Add this to `~/.config/fish/config.fish`:
        ~~~ fish
        pungi init - | source
        ~~~

      **General warning**: There are some systems where the `BASH_ENV` variable is configured
      to point to `.bashrc`. On such systems you should almost certainly put the above-mentioned line
      `eval "$(pungi init -)"` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you
      may observe strange behaviour, such as `pungi` getting into an infinite loop.
      See [#264](https://github.com/pyenv/pyenv/issues/264) for details.

4. **Restart your login session for the changes to take effect.**
   E.g. if you're in a GUI session, you need to fully log out and log back in.
   
   In MacOS, restarting terminal windows is enough (because MacOS runs shells
   in them as login shells by default).

5. [**Install Python build dependencies**](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) before attempting to install a new Python version.

6. **Install Python versions into `$(pungi root)/versions`.**
   For example, to download and install Python 2.7.8, run:
    ```sh
    pungi install 2.7.8
    ```
   **NOTE:** If you need to pass a `configure` option to a build, please use the
   ```CONFIGURE_OPTS``` environment variable.

   **NOTE:** If you want to use proxy to download, please set the `http_proxy` and `https_proxy`
   environment variables.

   **NOTE:** If you are having trouble installing a Python version,
   please visit the wiki page about
   [Common Build Problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems).


#### Upgrading

If you've installed Pungi using Homebrew, upgrade using:
```sh
brew upgrade pungi
```

If you've installed Pungi using the instructions above, you can
upgrade your installation at any time using Git.

To upgrade to the latest development version of pungi, use `git pull`:

```sh
cd $(pungi root)
git pull
```

To upgrade to a specific release of Pungi, check out the corresponding tag:

```sh
cd $(pungi root)
git fetch
git tag
git checkout v0.1.0
```

### Uninstalling pungi

The simplicity of pungi makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** Pungi managing your Python versions, simply remove the
  `pungi init` invocations from your shell startup configuration. This will
  remove Pungi shims directory from `PATH`, and future invocations like
  `python` will execute the system Python version, as it was before Pungi.

   `pungi` will still be accessible on the command line, but your Python
   apps won't be affected by version switching.

2. To completely **uninstall** Pungi, remove _all_ configuration lines for it
   from your shell startup configuration, and then remove
   its root directory. This will **delete all Python versions** that were
   installed under `` $(pungi root)/versions/ `` directory:
   
   ```sh
   rm -rf $(pungi root)
   ```

   If you've installed Pungi using a package manager, as a final step,
   perform the Pungi package removal. For instance, for Homebrew:

   ```
   brew uninstall pungi
   ```

### Advanced Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`pungi init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `pungi init` actually does.
Step 1 is done by `eval "$(pungi init --path)"`, the others are done by
`eval "$(pungi init -)"`.


1. **Sets up your shims path.** This is the only requirement for pungi to
   function properly. You can do this by hand by prepending
   `$(pungi root)/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `$(pungi root)/completions/pungi.bash` will set that
   up. There is also a `$(pungi root)/completions/pungi.zsh` for Zsh
   users.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `pungi rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows
   pungi and plugins to change variables in your current shell, making
   commands like `pungi shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `pungi` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `pungi init -`
or `pungi init --path`.

If you don't want to use `pungi init` and shims, you can still benefit
from pungi's ability to install Python versions for you. Just run
`pungi install` and you will find versions installed in
`$(pungi root)/versions`, which you can manually execute or symlink
as required.

### Uninstalling Python Versions

As time goes on, you will accumulate Python versions in your
`$(pungi root)/versions` directory.

To remove old Python versions, `pungi uninstall` command to automate
the removal process.

Alternatively, simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Python version
with the `pungi prefix` command, e.g. `pungi prefix 2.6.8`.


----


## Command Reference

See [COMMANDS.md](COMMANDS.md).


----

## Environment variables

You can affect how pungi operates with the following settings:

name | default | description
-----|---------|------------
`PUNGI_VERSION` | | Specifies the Python version to be used.<br>Also see [`pungi shell`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pungi-shell)
`PUNGI_ROOT` | `~/.pungi` | Defines the directory under which Python versions and shims reside.<br>Also see `pungi root`
`PUNGI_DEBUG` | | Outputs debug information.<br>Also as: `pungi --debug <subcommand>`
`PUNGI_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for pungi hooks.
`PUNGI_DIR` | `$PWD` | Directory to start searching for `.python-version` files.
`PYTHON_BUILD_ARIA2_OPTS` | | Used to pass additional parameters to [`aria2`](https://aria2.github.io/).<br>If the `aria2c` binary is available on PATH, pungi uses `aria2c` instead of `curl` or `wget` to download the Python Source code. If you have an unstable internet connection, you can use this variable to instruct `aria2` to accelerate the download.<br>In most cases, you will only need to use `-x 10 -k 1M` as value to `PYTHON_BUILD_ARIA2_OPTS` environment variable



## Development

The pungi source code is [hosted on
GitHub](https://github.com/pyenv/pyenv).  It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/bats-core/bats-core):

    bats test
    bats/test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/pyenv/pyenv/issues).


  [pungi-virtualenv]: https://github.com/pyenv/pyenv-virtualenv#readme
  [hooks]: https://github.com/pyenv/pyenv/wiki/Authoring-plugins#pungi-hooks

### Version History

See [CHANGELOG.md](CHANGELOG.md).

### License

[The MIT License](LICENSE)
