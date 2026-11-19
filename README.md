# Deedpoll CLI File Renaming Utility

Deedpoll is a simple, easy and useful bulk file renaming utility.
It exists to bring the simplistic but powerful renaming model of GUI utilities like Linux Mint's Bulky and Thunar Bulk Rename to other systems in a maximally portable way.

Deedpoll is made with Lua and should run in any Lua 5.1 or later interpreter, including LuaJIT. It requires LuaFileSystem.

## Guide

In most terminals, Deedpoll's output is colourful, offering easy semantic insight into rename operations.

```
Usage: deedpoll [MODE] [PARAMETERS] [OPTIONS] [FILES]

[MODE]
  case    (c)  Changes character cases.
  delete  (d)  Delete characters between specified positions.
  search  (s)  Search and replace within file contents.
  insert  (i)  Insert text into filename.
  replace (r)  Replace text in filename.

[PARAMETERS]
  ACTION  Case change to apply in case mode.
    title   (t)  Changes names to title case.
    lower   (l)  Changes names to lower case.
    upper   (u)  Changes names to upper case
    accents (a)  Removes accents in the file name.
    first   (f)  Makes first character uppercase.
  FIND  Find text for search/replace. Wildcards ? and * are supported.
  TEXT  Text for search/insert/replace. Use %n, %0n, %00n etc. to enumerate.

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
  -r/--recurse    Recurse directories for all files.
  -s=/--start=    Start number for incremented %n patterns.
  -t=/--to=       Position to delete to in delete mode.
  -v/--version    Show version information.
  -y/--yes        Rename files without confirmation step.

NOTES
  [FILES] will resolve to those in the current directory if omitted.
  Default behaviour is to operate on basename, with all values set to 1.
  Unless "mock" or "yes" are enabled, Deedpoll requires confirmation.
  For pos/to, pre/postfix the letter 'e' to the value to specify from the end.

EXAMPLES
  # Delete characters from 2nd to 5th letter
  deedpoll delete --pos=2 --to=5
  # Change whole filename including the extension to uppercase
  deedpoll case upper -n=full
  # Insert "text {n}" at start, incrementing in 2's, no confirmation
  deedpoll insert "text %n" -i=2 -y
  # Replace "old" with "new" in current directory except for "ignore.txt"
  deedpoll replace "old" "new" -d ignore.txt
```

### Regular Expression Support

At this time, Deedpoll does not support regular expression find and replace.
Other tools like [f2][1], [brename][2] and [rnr][3] offer this in a much better capacity.
Deedpoll exists to do simple renaming tasks with less mental effort than it would to make a regular expression.

[1]: https://github.com/ayoisaiah/f2
[2]: https://github.com/shenwei356/brename
[3]: https://github.com/ismaelgv/rnr

On the converse, Deedpoll enables the user to use Lua patterns, which are simpler albeit more limited (but still very capable).

## Install

Most systems should provide installable packages for Lua and LuaFileSystem.
Releases offers the ready to run script with a shebang added that can be used directly and placed with the user's other binaries.

Alternatively, clone the source and use `./make && ./make install` to install to */usr/local*.
The second argument can be set with a different install prefix, e.g. `./make install ~/.local`.

### Windows

Binaries for Windows (supporting XP and newer) are made with [luainstaller](https://github.com/Water-Run/luainstaller).

## TODO

- UNIT TESTS!! Verifying behaviour will be tedious with high liklihood of regressions until this is done
- Make feature complete
- Add translations method
- Build Windows version
