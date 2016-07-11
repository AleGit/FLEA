/* CYicesSample demonstrates the usage of The Yices SMT Solver's in Swift. */


// print version of installed Yices
print("Yices \(Yices.version) installed.")
// CYicesApiSamples.printTypes()
print("=================================")
// CTptpParsingApiSamples.printTypes()
print("=================================")

// FilePath.demo()

for path in ["Problems/PUZ001-1.p", "Problems/PUZ002-1.p", "Problems"] {
  print(">", path,path.fileSize, path.isAccessibleDirectory, path.isAccessibleFile)
  if let tptpFile = TptpFile(path:path) {
    print(tptpFile.dynamicType, tptpFile)
    tptpFile.printIt()
  }
}


// CTptpParsingApiSamples.demoStore()

print ("SUCCESS")
