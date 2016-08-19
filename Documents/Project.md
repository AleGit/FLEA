Project structure
===================
Overview
--------
The project' root directory contains the following 
directories and files.

- Alphabetically
    - `.build`
    - `Configs`
    - `Documents`
    - `Packages`
    - `Problems`
    - `Scripts`
    - **`Sources`**
    - **`Tests`**
    - **_`Package.swift`_**
    - _`README.md`_

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

### Configs
*[not supported yed]* 

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
