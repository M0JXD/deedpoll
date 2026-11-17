# Deedpoll CLI File Renaming Utility

Deedpoll exists to bring the simplistic but powerful abilities of renamers like Linux Mint's Bulky and Thunar Bulk Rename to other systems in a maximally portable way.
Deedpoll is made with Lua and should run in any Lua 5.1 or later interpreter, including LuaJIT. It requires LuaFileSystem.

## Usage

```
Usage: deedpoll [MODE] [PARAMETERS] [OPTIONS] [FILES]
Default behaviour is to operate on the basename. All option values default to 1.

[MODE]
  case    (c)  Changes character cases.
  delete  (d)  Delete characters from a position to another.
  search  (s)  Search and replace within file contents.
  insert  (i)  Insert text.
  replace (r)  Replace text.

[PARAMETERS]
  ACTION  Case change to apply in case mode.
    title   (t)  Changes names to title case.
    lower   (l)  Changes names to lower case.
    upper   (u)  Changes names to upper case
    accents (a)  Removes accents in the file name.
    first   (f)  Makes first character uppercase.
  FIND  Text to find in search/replace mode. Wildcards ? and * are supported.
  TEXT  Text for search/insert/replace mode. Use %n, %0n, %00n etc. to enumerate.

[OPTIONS]
  -c/--case         Enable case sensitivity in replace mode.
  -d/--disallow     Treat passed filenames as ones to disallow from current directory.
  -e/--exp          Enable regular expressions in replace mode find strings.
  -f/--full         Use full file listing including hidden dotfiles.
  -h/--help         Show help text.
  -i=/--increment=  Value to increment by for %n patterns in insert/replace mode.
  -m/--mock         Do a mock run without changing files or confirmation prompt.
  -n=/--name=       [(b)ase/(e)xt/(f)ull] operate on base, extensions or entire name.
  -o/--overwrite    Enable overwrite for insert mode.
  -p=/--pos=        Position to insert/replace/deletion from. Pre/postfix 'e' to specify from the end.
  -r/--recurse      Recurse directories for all files.
  -s=/--start=      Start number for incremented %n patterns in insert/replace mode.
  -t=/--to=         Position to delete to in delete mode. Pre/postfix 'e' to specify from the end.
  -v/--version      Show version information.
  -y/--yes          Rename files without confirmation step.

[FILES] will resolve to those in the current directory if omitted.

EXAMPLES
  deedpoll delete -p=2 -t=5 # Delete characters from 2nd to 5th letter
  deedpoll case upper -n=a # Change whole filename including the extension to uppercase
  deedpoll insert "insert %n" -i=2 -y # Insert "insert N" at start, incrementing in 2's, no confirm
```

### Regex Support

Undecided whether to use reLua or lrexlib or one of the many others on LuaRocks.
Or offer Lua patterns instead.

### Examples

## Install

### Unix Systems

Most systems should provide installable packages for Lua and LuaFileSystem.
Releases offers the ready to run script that can be used directly.


Alternatively, close the source and use `make && sudo make install` to install to */usr/local*. The **INSTALL** variable can be set with a different install prefix, e.g. `make install INSTALL=~/.local`.

### Windows

Binaries for Windows (supporting XP and newer) are made with [luainstaller](https://github.com/Water-Run/luainstaller).
