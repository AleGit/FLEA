/* CYicesSample demonstrates the usage of The Yices SMT Solver's in Swift. */



import Foundation

// print("\(Process.arguments)")
// for name in ["PATH", "USER", "TPTP_PATH"] {
//   print(name, Process.Environment.get(variable:name))
// }



/*

// print version of installed Yices
// print("Yices \(Yices.version) installed.")
// CYicesApiSamples.printTypes()
// print("=================================")
// CTptpParsingApiSamples.printTypes()
// print("=================================")
*/
// FilePath.demo()

for path in ["Problems/PUZ001-1.p", "Problems/PUZ002-1.p", "Problems",
"Problems/PUZ001+1.p"] {
  print(">", path,path.fileSize, path.isAccessibleDirectory, path.isAccessible)
  if let tptpFile = TptpFile(path:path) {
    print(tptpFile.dynamicType, tptpFile)
    tptpFile.printIt()
  }
}


// CTptpParsingApiSamples.demoStore()


print ("DONE")
