# FLEA *library*, *tests, and binary*
**F**irst order **L**ogic with **E**quality theorem **A**ttesting

- *still in development*

### Platforms:
- Mac (OS X El Capitan, macOS Sierra)
- Linux 64-bit (Ubuntu 14.04, 15.10, 16.04)

### Prerequisites

[Yices](http://yices.csl.sri.com), 
[Z3](https://github.com/Z3Prover/z3), 
and [Swift 3](https://swift.org/download/) have to be installed.

- Install [Yices](http://yices.csl.sri.com) and check:
```
$ yices -V
Yices 2.5.1
```

- Install [Z3](https://github.com/Z3Prover/z3) and check:
```
$ z3  --version
Z3 version 4.5.1 - 64 bit
```
On Linux the z3 header files in `/usr/include` have to be linked into `/usr/local/include`.

```
$ Scripts/z3headers.sh
$ ls /usr/local/include
… yices.h … z3.h …
```




- Install [Swift 3](https://swift.org/download/) and check:
```
$ swift -version
Apple Swift version 3.0.2 (swiftlang-800.0.63 clang-800.0.42.1) # Mac
Swift version 3.0 (swift-3.0-RELEASE)                       # Linux

$ xcode-select -p          # Mac only
/Applications/Xcode.app/Contents/Developer
```

### Installation

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
The first (failing) `swift build` is necessary to download the system packages.
But it cannot succeed because the parsing lib is not installed yet.

- Run all tests / tests in class NodeTests / NodeTests.testInit()
```
$ Scripts/tests.sh            # i.e. $ swift test -Xlinker -L/usr/local/lib
$ Scripts/tests.sh Node       # i.e. $ swift test -s FLEATests.NodeTests
$ Scripts/tests.sh Node Init  # i.e. $ swift test -s FLEATests.NodeTests/testInit
```

- Build [1] and run the release binary
```
$ Scripts/build.sh -c release -Xlinker -L/usr/local/lib   # Mac?
$ Scripts/build.sh -c release -Xlinker -L/usr/lib         # Linux?
$ .build/release/FLEA --demo
```

[1]: The script copies `main.swift` into `Sources` and then envokes `swift build`.
After the build it removes `main.swift` from `Sources`, because
on Linux `Sources/main.swift` and `Tests/LinuxMain.swift` clash when building tests.
