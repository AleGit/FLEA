# FLEA
A **F***irst* *order* **L***ogic* w*ith* **E***quality* *theorem* **A***ttester* still in development.

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
- Clone, build and run [FLEA](https://github.com/AleGit/FLEA):
```
$ git clone https://github.com/AleGit/FLEA
$ cd FLEA
$ swift build                                       # fails after download
$ pushd Packages/CTptpParsing-1.0.0                 # or 1.0.1 or ...
$ sudo make install                                 # install tptp parsing lib
$ popd
$ swift build -c release                            # Linux
$ swift build -c release -Xlinker -L/usr/local/lib  # Mac path to lib
$ .build/release/FLEA --demo                        # list available demos
```
The first (failing) `swift build` is necessary to download the system packages. But it cannot succeed because the parsing lib is not installed yet.

### Testing

- macOS: run all tests

```
$ swift build -Xlinker -L/usr/local/lib
$ swift test
```

