# FLEA *library* & *tests*
**F** irst order **L** ogic with **E** quality theorem **A** ttester

- *library still in development*
- *see [FleaBite](https://AleGit/FleaBite) for an executable and some demos.*

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
$ xcode-select -pxcode-select -p
/Applications/Xcode-beta.app/Contents/Developer
```
- Download and unpack package [TPTP-v6.4.0.tgz](http://www.cs.miami.edu/~tptp/) (or newer).
In your home directory create a symbolic to the unpacked `TPTP-v6.4.0` directory and check.
```
ls ~/TPTP
Axioms		Documents	Generators	Problems	README		Scripts		TPTP2X
```
This will enable the unit tests to find problems and axioms.
(Alternatively you can set the environment variable `TPTP_ROOT`
to the full path to the unpacked `TPTP-v6.4.0` directory.)
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
