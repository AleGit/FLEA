import XCTest
@testable import FLEATestSuite

XCTMain([
  testCase(PositionTests.allTests),
  testCase(ProcessTests.allTests),
  testCase(SharingNodeTests.allTests),
  testCase(SmartNodeTests.allTests),
  testCase(SubstitutionTests.allTests),
  testCase(UnificationTests.allTests),
  testCase(WeakSetTests.allTests)
  ])
