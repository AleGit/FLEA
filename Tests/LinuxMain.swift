import XCTest
@testable import FLEATestSuite

XCTMain([
  testCase(DictionarySubstitutionTests.allTests),
  testCase(DictionaryUnificationTests.allTests),

  testCase(KinNodeTests.allTests),
  testCase(MiscPerformanceTests.allTests),
  testCase(PositionTests.allTests),
  testCase(ProcessTests.allTests),
  testCase(SharingNodeTests.allTests),
  testCase(SmartNodeTests.allTests),
  testCase(StringPathTests.allTests),
  testCase(SubstitutionTests.allTests),
  testCase(SyslogTests.allTests),
  testCase(TptpFileTests.allTests),
  testCase(UnificationTests.allTests),
  testCase(WeakSetTests.allTests)
  ])
