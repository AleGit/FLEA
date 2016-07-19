# FLEA
A **F***irst* *order* **L***ogic* w*ith* **E***quality* *theorem* **A***ttester* library still in development.

### Platforms:
- Mac (OS X El Capitan, macOS Sierra)
- Linux 64-bit (Ubuntu 14.04, 15.10)

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
- Clone and build [FLEA](https://github.com/AleGit/FLEA):
```
$ git clone https://github.com/AleGit/FLEA
$ cd FLEA
$ swift build                                       # fails after download
$ pushd Packages/CTptpParsing-1.0.0                 # or 1.0.1 or ...
$ sudo make install                                 # install tptp parsing lib
$ popd
$ swift build                                       # Linux
$ swift build -Xlinker -L/usr/local/lib             # Mac path to lib
$ swift test                                        # run all tests
```
The first (failing) `swift build` is necessary to download the system packages. But it cannot succeed because the parsing lib is not installed yet.

See [FleaBite](https://github.com/AleGit/FleaBite) for an
executable with a list of nice demos.
