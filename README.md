[![Build status](https://ci.appveyor.com/api/projects/status/9xwg49m6124xa2pp/branch/master?svg=true
)](https://ci.appveyor.com/project/julian-r/file-windows)

This aims to have everything one needs to build file on windows with visual studio.

## Checkout with submodules

```sh
git submodule update --init --recursive
```

## External Dependencies

- *regex*: I am using [PCRE2](http://www.pcre.org/) version 10.30.
 Unfortunately this is not available on github with tags, so I commited it in this repo.
 I copied `pcre2posix.h` to `regex.h`.
- *dirent*: Dirent is not available on windows, so I used a implementation from [tronkko](https://github.com/tronkko/dirent).
- *getopt*: A similar problem exists with getopt, so I used a implementation from [skandhurkat](https://github.com/skandhurkat/Getopt-for-Visual-Studio).

## Linking

- all the dependencies are statically linked or compiled into the dll
- There is a `.def` file in windows headers describing the exports for the linker
- Since dirent defines some of the symbols used in files `readelf.c` and `magic.c` the include is "patched" into them in the `CMakeLists.txt`

## Updating file

- Checkout the version in the `file` submodule.
- Update `CMakeLists.txt`
- Update `appveyor.yml`

## Updating pcre2

- I disabled the test in the `CMakeFile.txt` manually, the rest is vanilla.
