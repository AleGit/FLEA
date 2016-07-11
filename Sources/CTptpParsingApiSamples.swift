import CTptpParsing

struct CTptpParsingApiSamples {

  static func demoStore() {
    prlcParsingStore = prlcCreateStore(1_000_000)
    guard let store = prlcParsingStore else {
      print("Error: creation of store failed.")
      return
    }
    defer {
      prlcDestroyStore(store)
    }
    print("symbols",store.pointee.symbols.size)
    print("p_nodes",store.pointee.p_nodes.size)
    print("t_nodes",store.pointee.t_nodes.size)
  }
  static func printTypes() {
    print("=========================================================")
    print("types:")

    print("prlcParseFile :", prlcParseFile.dynamicType)
    print("prlcDestroyStore :", prlcDestroyStore.dynamicType)
    print(" ")
    print("prlcStoreSymbol :", prlcStoreSymbol.dynamicType)

    print("=========================================================")


  }


}
