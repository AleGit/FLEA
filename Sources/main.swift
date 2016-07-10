/* CYicesSample demonstrates the usage of The Yices SMT Solver's in Swift. */


// print version of installed Yices
print("Yices \(Yices.version) installed.")

// FilePath.demo()

if let tptpFile = TptpFile(path:"Problems/PUZ001-1.p") {
  print(tptpFile.dynamicType, tptpFile)
}

// demonstrate quantifier free predicate logic
// Yices.Samples.demo()

// Parsing.demoStore()
// Parsing.demoParse()


CTptpParsingApiSamples.printTypes()

// CTptpParsingApiSamples.demoStore()
