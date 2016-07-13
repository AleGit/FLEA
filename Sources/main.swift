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
    // tptpFile.printIt()
    tptpFile.printInputs()
  }
}

let (tptpFile,runtime) = measure {
  TptpFile(path:"/Users/Shared/TPTP/Problems/HWV/HWV134-1.p")
}



if let tptpFile = tptpFile {
  print("\(tptpFile) was parsed in \(runtime) s.")
  let all = measure {tptpFile.inputs.reduce(0) { (a,_) in a + 1}}
  let c = measure {tptpFile.cnfs.reduce(0) { (a,_) in a + 1 }}
  let f = measure {tptpFile.fofs.reduce(0) { (a,_) in a + 1 }}
  let i = measure {tptpFile.includes.reduce(0) { (a,_) in a + 1 }}
  print("\(tptpFile)", all, c,f,i)
}


// CTptpParsingApiSamples.demoStore()


print ("DONE")
