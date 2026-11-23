# Deedpoll - Bulk File Renaming Utility

Deedpoll is a simple and useful CLI bulk/batch file renaming utility.
It exists to bring the simplistic but powerful renaming model of GUI utilities like Linux Mint's Bulky and Thunar Bulk Rename to other systems in a maximally portable way.

Deedpoll is made with Lua and should run in any Lua 5.1 or later interpreter, including LuaJIT. It requires LuaFileSystem.

## Usage

```
Usage: deedpoll [MODE] [PARAMETERS] [OPTIONS] [FILES]

[MODE]
  accent  (a)  Removes accents in the file name.
  delete  (d)  Delete characters between specified positions.
  first   (f)  Makes first character uppercase.
  insert  (i)  Insert text into filename.
  lower   (l)  Changes names to lower case.
  replace (r)  Replace text in filename.
  title   (t)  Changes names to title case.
  upper   (u)  Changes names to upper case.

[PARAMETERS]
  FIND  Find text for replace mode. Wildcards ? and * are supported.
  TEXT  Text for insert/replace mode. Use %n, %0n, %00n etc. to enumerate.

[OPTIONS]
  -c/--case       Enable case sensitivity in replace mode.
  -d/--disallow   Listed files are not processed from current directory.
  -e/--exp        Treat replace mode find strings as Lua patterns.
  -f/--full       Use full file list including hidden dotfiles.
  -h/--help       Show help text.
  -i=/--inc=      Increment step for %n patterns in insert/replace mode.
  -m/--mock       Mock run without changing files or confirmation prompt.
  -n=/--name=     [(b)ase/(e)xt/(f)ull] aspect of filename to change.
  -o/--overwrite  Enable overwrite for insert mode.
  -p=/--pos=      Start position for insert/delete.
  -r/--recurse    Recurse search for files. Directories are not renamed.
  -s=/--start=    Start number for incremented %n patterns.
  -t=/--to=       Position to delete to in delete mode.
  -v/--version    Show version information.
  -y/--yes        Rename files without confirmation step.

Default behaviour is to operate on basename, with all values set to 1.
Unless `--mock` or `--yes` are enabled, Deedpoll requires confirmation.
For `--pos`/`--to`, pre/postfix 'e' to the value to specify from the end.
To work with hidden dotfiles using `--full`, also set `--name=full`.
`--case` has no effect on Windows as the filesystem is case insensitive.
If no files are listed, the contents of the current directory will be used.

EXAMPLES
  # Change whole filename including the extension to uppercase
  deedpoll upper -n=full
  # Delete characters from 2nd to 5th letter
  deedpoll delete --pos=2 --to=5
  # Insert "text {n}" at start, incrementing in 2's, no confirmation
  deedpoll insert "text %n" -i=2 -y
  # Replace "old" with "new" in current directory except for "old_ignore.txt"
  deedpoll replace "old" "new" -d old_ignore.txt
```

### Color

In most terminals, Deedpoll's output is colourful:

- Directories are shown in bold blue, akin to `ls`.
- In the case where a rename does not cause a change, Deedpoll uses a cyan arrow instead of a yellow one.
- Parameters/option overviews and informational text use colours to make them easier to read.

### Arguments

Deedpoll does not heaviliy sanitise it's CLI arguments.
For example, `deedpoll any` will resolve to the remove accent mode, as the argument begins with *a*.

**insert** and **replace** mode require parameters.
Parameters are expected as the immediate arguments after specifying the mode, and are not flagged like options.

Options are parsed as full words, e.g. `-i 2` will not be parsed, you must use `-i=2`.

### Regular Expression Support

At this time, Deedpoll does not support regular expression find and replace.
Other tools like [f2][1], [brename][2] and [rnr][3] offer this in a much better capacity.
Deedpoll exists to do simple renaming tasks with less mental effort than it would take to make a regular expression.

[1]: https://github.com/ayoisaiah/f2
[2]: https://github.com/shenwei356/brename
[3]: https://github.com/ismaelgv/rnr

On the converse, Deedpoll enables the user to use Lua patterns, which are simpler albeit more limited (but still very capable).

## Install

### Unix-like

Most systems should provide installable packages for [Lua][4] and [LuaFileSystem][5].
Releases offers the ready to run script with a shebang added that can be used directly, and placed with the user's other binaries.

[4]: https://www.lua.org/
[5]: https://lunarmodules.github.io/luafilesystem/

Alternatively, use Deedpoll's custom Lua build system. Clone the source and use `./make && ./make install` to install to */usr/local*.
The second argument can be set with a different install prefix, e.g. `./make install ~/.local`.

### Windows

If you have a Lua installation with LuaFileSystem you will be able to run Deedpoll, but that is not simple for an end user.
For development purposes, I've found the easiest way to achieve that is with [MSYS2][6] and its dedicated packages.

For distribution, Deedpoll's build command for Windows grabs Lua from [LuaBinaries][7], and precompiled LFS from the [ZeroBrane Studio][8] source.
It bundles everything into a folder and creates a batch file to start it. You can then drop this set of files somewhere on your *PATH* and use `deedpoll.bat`.
The build system makes bundles for Lua 5.2 and Lua 5.4, as the newer version's precompiled LFS fails to run on Windows XP.

[6]: https://www.msys2.org/
[7]: https://luabinaries.sourceforge.net/
[8]: https://studio.zerobrane.com/

## Development

Deedpoll includes it's own "build" system and test suite created in Lua, contained across the *make* and *tests.lua* files.

Deedpoll use a forked version of [ansicolors][1] to provide colours, which is bundled into the main source.
*ansicolors* is also used for the *make* system, so is also stored separately under *lib/*.
Deedpoll is written in such a way that updates to *ansicolors* can be easily pasted into the source code.

Some of the code within Deedpoll originates from snippets about the internet, those snippets have citations and license information within the source.
Other code is translated to Lua from Linux Mint's Bulky. Other than that, Deedpoll's code was generated by a human.

As far as I see it, *ONLY* the snippet and its modifications are under the source's license. The rest of the code it MIT Licensed.
If you are the license owner and wish to contest this, please open an issue or contact me.

The *make* system offers the following options:

- build (default) - "Build" Deedpoll for the current platform into *build/* (inserting a shebang to the script)
- install - Install to system, requires `build` to have been run previously.
- uninstall - Uninstall from system. Note that the make system does not remember custom prefixes.
- test - Run the test suite. Pass `-V` or `--verbose` to see Deedpoll's output for the tests.
- clean - Delete *build/* and any lingering test files.

### Tests

New tests are added to *tests.lua* with the `test{}` function.
They are simply Lua tables detailing aspects of the test.

Tests are of the form:

```lua
-- Template for Deedpoll's tests.
test{
    name = 'Descriptive name for the test.',
    cmd = 'deedpoll [MODE] [OPTIONS]',
    files = {
        'filenames_to_pass_at_cli (optional).txt'
    },
    input = {
        'starting_filename.txt'
    },
    expected = {
        'expected_file_name.txt'
    }
}
```
