# FLEA
**F***irst* *order* **L***ogic* w*ith* **E***quality* *theorem* **A***ttester*

### Platforms:
- Mac (OS X El Capitan, macOS Sierra)
- Linux 64-bit (Ubuntu 14.04 or 15.10)
- Platform with clang, libicu-dev, Swift 3 (untested)

### Installation

- Install [Yices](http://yices.csl.sri.com) and check:
```
$ yices -V
Yices 2.4.2
```
- Install [Swift 3](https://swift.org/download/) and check:
```
$ swift -version
Apple Swift version 3.0 ...
```
- Build and run [FLEA](https://github.com/AleGit/FLEA):
```
$ git clone https://github.com/AleGit/FLEA
$ cd FLEA
$ make build                              # will download packages, but build will fail
$ pushd Packages/CTptpParsing-1.0.0       # or 1.0.1 or ...
$ sudo make install                       # will intall tptp parsing lib
$ popd
$ swift build                             # Linux
$ swift build -Xlinker -L/usr/local/lib   # Mac: linker needs path to lib
$ .build/debug/FLEA --demo                # run a demo
```

