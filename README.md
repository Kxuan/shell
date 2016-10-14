# Utilities on ArchLinux
I write these programs because I need them.

## Install
1. git clone git@github.com:Kxuan/shell.git
2. backup your ~/.bashrc
3. symlink shell/.bashrc to $HOME/.bashrc
4. symlink shell/helper to $HOME/.bin/helper
5. choose some programs in shell/, and symlink them to $HOME/.bin

## pkg
a short helper command for pacman, using sudo automatically.

```
usage: pkg <action> [arguments]

actions:
  ui, iu, su, sys, systemupgrade   upgrade the system
  u, up, update                    update the software list
  i, inst, install, a, add,        install packages
                                   (use "pkg i -h" to get more infomation)
  if, info                         print the infomation of the package
  r, remove, un, uninstall         uninstall packages
  s, se, search                    search a packages (pacsearch)
  f, file, path, filename          search a file in all packages (pkgfile)
  binary                           search a binary file (pkgfile -bs)
  b                                search a binary file with regex support
  bi, ib, installbinary            search a binary file with regex support and install it
  l, list                          list the contents of a package

```

Example:
```
$ pkg ui
$ pkg ib sar
```

## run
Run a program with condition.

```
usage: run <-f | -t timeout> [ -s SIGNAL ] program arguments
options:
  -f        run the program util the exit status of the program is 0.
  -t        run the program and send a SIGNAL after timeout second.
  -s        specify the timeout SIGNAL (default is SIGINT)
```

Example:

```
$ run -f ssh x.x.x.x
$ run -t 1 -s KILL sleep 1d
```
## dehex
Decode hex stream into raw.

(You should compile dehex.c to dehex by yourself)
Example:

```
dehex <file.hex >file.raw
```


