import XCTest
@testable import FLEATests

XCTMain([
    testCase(AuxiliaryTests.allTests),
    
    testCase(ClausesTests.allTests),
    testCase(CommandLineTests.allTests),
    testCase(CTptpParsingApiTests.allTests),
    testCase(CYicesApiTests.allTests),
    
    testCase(DemoTests.allTests),
    testCase(DescriptionTests.allTests),
    testCase(DictionarySubstitutionTests.allTests),
    testCase(DictionaryUnificationTests.allTests),
    
    testCase(KinNodeTests.allTests),
    
    testCase(NodePathsTests.allTests),
    testCase(NodePropertiesTests.allTests),
    testCase(NodeTests.allTests),
    
    // testCase(ParseTptpTests.allTests), // to expensive

    testCase(PositionTests.allTests),
    testCase(ProverletTests.allTests),
    testCase(ProverTests.allTests),
    
    testCase(SharingNodeTests.allTests),
    testCase(SmartNodeTests.allTests),
    testCase(StringLiteralTests.allTests),
    testCase(StringPathTests.allTests),
    
    testCase(StringTypedTests.allTests),
    testCase(SubstitutionPerformanceTests.allTests),
    testCase(SubstitutionTests.allTests),
    testCase(SyslogTests.allTests),
    
    testCase(TptpFileTests.allTests),
    testCase(TrieTests.allTests),
    
    testCase(UnificationTests.allTests),
    testCase(URLTests.allTests),
    
    testCase(VersionTests.allTests),
    testCase(WeakSetTests.allTests),
    testCase(YicesTests.allTests),
    testCase(Z3Tests.allTests),
])
