Project structure
===================
Overview
--------
The project' root directory contains the following
directories and files.

- Alphabetically
    - `.build` – i.e. artefacts
    - `Configs` – configuration files for tests and executable
    - `Documents` – additional information to various topics
    - `Packages` – resolved external dependencies defined in ./Package.swift
    - `Problems` – _local_ problem files (deprecated)
    - `Scripts` – helper bash scripts and `main.swift`
    - **`Sources`** – the implementation
    - **`Tests`** – the unit tests
    - **_`Package.swift`_** – definition of external dependencies
    - _`README.md`_ – instructions to build FLEA or to run tets

- Grouped by role
    - source code: `Sources`, `Tests`, *`Packages.swift`*
    - build process: `Packages`, `.build`
    - runtime: `Configs`, `Problems`
    - helpers: `Scripts`
    - documentation: `Documents`, _`README.md`_

Details
-------
### .build
This directory contains the output of swift debug or release builds.

### Configs _[Preliminary]_
This directory holds configuration files for logging.
The confiuration file will be selected by command line argument
or based on the process name, e.g.
- `/path/to/name.xctest` -> `xctest.logging`
- `.build/debug/FLEA` -> `FLEA.logging`

A logging configuration file determines the general and specific
loggging priorities. At runtime a logging message with priority »priortiy«
and originating from »file«/»function« (with »scope« _n/a_) will be written:
- if the message »priority« is prior (i.e.smaller or equal)
  to the maximal logging priority _and_
  - the message »priorty« is prior to the minimal logging priority
  - _or_ the »file«/»function« priority value exists
      _and_ »priority« is prior to it,
  - _or_ the "»file»/»function»" priority does not exist,
    the »file» priority value exists,
      _and_ the message »priority« is prior to it,
  - _or_ neither the "»file»/»function»" priority value
      nor the "»file»" priority value exist, and
      the message «priority« is prior to the default priority.

#### Logging configuration file _[preliminary_]
- comment lines start with \# and will be ignored
- whitespace lines (spaces and tabs) will be ignored
- lines with "key" : "value" pairs will be read
- possible keys are
    - "+++" the key for the maximal logging priority,
      i.e. logging messages with a poseterior priority
      than the maximal priority will never be logged.
    - "---" the key for the minimal logging priority,
      i.e. logging messages with a prior priority than
      the miniaml logging priorty will allways be logged.
    - "+++" the key for the default logging priority.
    - "<file>" the logging priortiy for a source file.
    - "<file>/<function" the logging priority for a
      function in a file.
- possible values are logging priorities

### Documents
Concepts, ideas, overviews, etc.

### Packages
The swift buid process uses the file `Package.swift` to
resolve dependecies to (system) modules. These modules source
code will be stored in `Packages`.

### Problems
Problem and axiom files for tests, additionally **FLEA**
makes use of `--tptp_root`, `$TPTP_ROOT`,
or`~/TPTP` to find problem and axiom files by name.

### Scripts

The scripts in the `Scripts` directory are not part of the **FLEA**
swift package, but are shortcuts for project maintainance tasks.
The scripts must be started in the root directory of the project, e.g.

`$ Scripts/tests.sh`

- `tests` builds project and runs tests. The script takes
  up to two arguments. The first would the name of a test
  class (without the suffix `Tests`) and the second one the
  name of a test method (without the prefix `test`)
  - `$ Scripts/tests.sh` will run all tests.
  - `$ Scripts/tests.sh Trie` will run all tests in class `TrieTests`
  - `$ Scripts/tests.sh Trie TrieClass` will run `testTrieClass()`
    in class `TrieTests`
- `ctests` cleans the project, calls `tests`.
- `uptag101` sets git tag *1.0.1* locally
- `deltag101` deletes git tag *1.0.1* locally
- `retag100` moves (deletes and adds) tag *1.0.0*
   to newest commit locally and remotely.

### Sources

### Tests
