# FLEA *library*, *tests, and binary*
**F**irst order **L**ogic with **E**quality theorem **A**ttesting

- *still in development*

### Platforms:
- Mac (OS X El Capitan, macOS Sierra)
- Linux 64-bit (Ubuntu 14.04, 15.10, 16.04)

### Prerequisites

[Yices](http://yices.csl.sri.com),
[Z3](https://github.com/Z3Prover/z3),
and [Swift 3](https://swift.org/) have to be installed.

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




- Intstall [Swift 4 Release](https://swift.org/download/#using-downloads)
and check:
```
$ swift -version
Apple Swift version 4.0 (swiftlang-900.0.65 clang-900.0.37) # Mac
Swift version 4.0 (swift-4.0-RELEASE)                       # Linux

$ xcode-select -p          # Mac only
/Applications/Xcode.app/Contents/Developer
```

### Installation

- Download and unpack package [TPTP-v6.4.0.tgz](http://www.cs.miami.edu/~tptp/TPTP/Distribution/TPTP-v6.4.0.tgz)
(or newer) from [TPTP](http://www.cs.miami.edu/~tptp/) .
Create a symbolic link to the unpacked `TPTP-v6.y.z` directory
in your home directory, and check:
```
ls ~/TPTP
Axioms		Documents	Generators	Problems	README		Scripts		TPTP2X
```
This will enable the unit tests to find problem and axiom files.
(Alternatively you can set the environment variable `TPTP_ROOT`
to the full path to the unpacked `TPTP-v6.4.0` directory.)
- Clone, build and run [FLEA](https://github.com/AleGit/FLEA) tests:
```
$ git clone https://github.com/AleGit/CTptpParsing
$ cd CTptpParsing
$ sudo make install
$ cd ..
$ git clone https://github.com/AleGit/FLEA
$ cd FLEA
$ swift build -Xlinker -L/usr/local/lib             # linker path to tptp parsing lib
$ swift test -l                                     # list all tests
$ swift test                                        # run all tests
```

- Run all tests / tests in `class NodeTests` / `NodeTests.testInit()` only:
```
$ Scripts/tests.sh            # i.e. $ swift test -Xlinker -L/usr/local/lib
$ Scripts/tests.sh Node       # i.e. $ swift test -s FLEATests.NodeTests
$ Scripts/tests.sh Node Init  # i.e. $ swift test -s FLEATests.NodeTests/testInit
```

- Build [1] and run the release binary
```
$ Scripts/build.sh -c release -Xlinker -L/usr/local/lib   # parser and yices libraries
$ .build/release/FLEA --demo
```

- Solve the [Dreadbury Mansion](http://www.cs.miami.edu/~tptp/cgi-bin/SeeTPTP?Category=Problems&Domain=PUZ&File=PUZ001-1.p) mystery in a second
```
$ .build/release/FLEA --problem PUZ001-1 --timeout 1
```

[1]: The script creates a copy of  `Scripts/main.swift` in `Sources` and envokes `swift build` afterwards.
When the build is done the script removes `Sources/main.swift`. 
Otherwise `Sources/main.swift` and `Tests/LinuxMain.swift` would clash when building tests on Linux.
