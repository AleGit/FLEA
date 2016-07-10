import CTptpParsing

struct Parsing {
  static func size(file: UnsafeMutablePointer<FILE>) -> size_t {
    var size = 0 as size_t
    fseek(file,0,SEEK_END)
    size = ftell(file)
    rewind(file)
    return size
  }

  static func demoParse() {
    let path = "Problems/PUZ001-1.p"
    guard let file = fopen(path, "r") else {
      print("ERROR: could not open '\(path)'.")
      return
    }
    defer {
      print("close file")
      fclose(file)
    }

    let size = self.size(file:file)
    guard size > 0 else {
      print("ERROR: empty file \(path)")
      return
    }

    print(path, size)
    var store = prlcCreateStore(size)
    defer {
      print("destroy store")
      prlcDestroyStore(&store)
    }

    /* parsing */
    prlc_in = file;
    prlc_restart(file);
    prlc_lineno = 1;

    prlcParsingStore = store
    prlcParsingRoot = prlcStoreNodeFile (prlcParsingStore,path,nil);

    let code = prlc_parse ()
    let root = prlcParsingRoot
    prlcParsingStore = nil
    prlcParsingRoot = nil
    /* parsing end */

    guard code == 0 else {
      print("ERROR: parse return code = \(code)")
      return
    }

    if let cstring = root?.pointee.symbol, let string = String(validatingUTF8:cstring) {
      print(cstring,string)
    }

    print(root, root.dynamicType, root?.pointee.symbol.dynamicType)
}

}
