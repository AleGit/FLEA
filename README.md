# FLEA *library* & *tests*
**F**irst order **L**ogic with **E**quality theorem **A**ttesting

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
- Install [Swift 3 Preview 4](https://swift.org/download/) and check:
```
$ swift -version                  
Apple Swift version 3.0 (swiftlang-800.0.41.2 clang-800.0.36) # Mac
Swift version 3.0 (swift-3.0-PREVIEW-4)                       # Linux

$ xcode-select -pxcode-select -p          # Mac only
/Applications/Xcode-beta.app/Contents/Developer
```

- Download and unpack package [TPTP-v6.4.0.tgz](http://www.cs.miami.edu/~tptp/) (or newer).
Create a symbolic link to the unpacked `TPTP-v6.4.0` directory 
in your home directory, and check:
```
ls ~/TPTP
Axioms		Documents	Generators	Problems	README		Scripts		TPTP2X
```
This will enable the unit tests to find problems and axioms.
(Alternatively you can set the environment variable `TPTP_ROOT`
to the full path to the unpacked `TPTP-v6.4.0` directory.)
- Clone, build and run [FLEA](https://github.com/AleGit/FLEA) tests:
```
$ git clone https://github.com/AleGit/FLEA
$ cd FLEA
$ swift build                                       # fails after download
$ pushd Packages/CTptpParsing-1.0.0                 # or 1.0.1 or ...
$ sudo make install                                 # install tptp parsing lib
$ popd
$ swift build -Xlinker -L/usr/local/lib             # linker path to tptp parsing lib
$ swift test -l                                     # list all tests
$ swift test                                        # run all tests
```
The first (failing) `swift build` is necessary to download the system packages. But it cannot succeed because the parsing lib is not installed yet.

- Build (workaround) and run a binary
```
$ Scripts/build.sh -c release -Xlinker -L/usr/lib
$ .build/release/FLEA --demo
```
The build workaround is necessary because otherwise `Sources/main.swift` 
and `Tests/LinuxMain.swift` would clash on Linux when building the tests.

