import XCTest
@testable import FLEATestSuite

XCTMain([
  testCase(PositionTests.allTests),
  testCase(ProcessTests.allTests),
  testCase(SharingNodeTests.allTests),
  testCase(SmartNodeTests.allTests),
  testCase(StringPathTests.allTests),
  testCase(SubstitutionTests.allTests),
  testCase(TptpFile.allTests),
  testCase(UnificationTests.allTests),
  testCase(WeakSetTests.allTests)
  ])
