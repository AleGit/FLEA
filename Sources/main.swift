import Foundation

print(Process.arguments)

let (tptpFile,runtime) = measure {
  TptpFile(path:"/Users/Shared/TPTP/Problems/HWV/HWV134-1.p")
}
print(tptpFile, runtime)

for path in ["Problems/PUZ001-1.p", "Problems/PUZ002-1.p", "Problems",
"Problems/PUZ001+1.p"] {
  print(">", path,path.fileSize, path.isAccessibleDirectory, path.isAccessible)
  let (tptpFile,runtime) = measure { TptpFile(path:path) }
  print(path,runtime)
  if let tptpFile = tptpFile {
    tptpFile.printInputs()
  }
}
