import XCTest
@testable import FLEATestSuite

XCTMain([
  testCase(AuxiliaryTests.allTests),
  testCase(CTptpParsingApiTests.allTests),
  testCase(CYicesApiTests.allTests),
  testCase(DescriptionTests.allTests),
  // testCase(DemoTests.allTests),
  testCase(DictionarySubstitutionTests.allTests),
  testCase(DictionaryUnificationTests.allTests),

  testCase(KinNodeTests.allTests),
  testCase(NodePathsTests.allTests),
  // testCase(ParseTptpTests.allTests),
  testCase(PositionTests.allTests),

  testCase(ProcessTests.allTests),
  testCase(SharingNodeTests.allTests),
  testCase(SmartNodeTests.allTests),
  testCase(StringLiteralTests.allTests),

  testCase(StringPathTests.allTests),
  testCase(SubstitutionPerformanceTests.allTests),
  testCase(SubstitutionTests.allTests),
  testCase(SyslogTests.allTests),

  testCase(TptpFileTests.allTests),
  testCase(TrieTests.allTests),
  testCase(UnificationTests.allTests),
  testCase(URLTests.allTests),
  testCase(WeakSetTests.allTests),
  testCase(YicesTests.allTests)
  ])
