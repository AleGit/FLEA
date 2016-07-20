import XCTest
@testable import FLEATestSuite

XCTMain([
  testCase(FirstTests.allTests),
  testCase(SharingNodeTests.allTests),
  testCase(SmartNodeTests.allTests),
  testCase(SubstitutionTests.allTests),
  testCase(UnificationTests.allTests),
  testCase(WeakCollectionTests.allTests)
  ])
