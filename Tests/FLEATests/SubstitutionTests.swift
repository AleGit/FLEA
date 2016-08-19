import XCTest

@testable import FLEA

public class SubstitutionTests : FleaTestCase {
  static var allTests : [(String, (SubstitutionTests) -> () throws -> Void)] {
    return [
      ("testBasics", testBasics)
    ]
  }

  func testBasics() {
    let X_a : Instantiator = [Q.X : Q.a]
    let Y_b : Instantiator = [Q.Y: Q.b]
    let Z_c : Instantiator = [Q.Z : Q.c]
    let XYZ_abc : Instantiator = [Q.X : Q.a, Q.Y: Q.b, Q.Z : Q.c]

    XCTAssertEqual("\(type(of:X_a)))","Instantiator<SmartNode>)", nok)

    guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc.description,lcombined.description,"\(XYZ_abc) ≠ \(lcombined) \(nok)")

    guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived. \(nok)")
      return
    }

    XCTAssertEqual(XYZ_abc, rcombined,"\(XYZ_abc) ≠ \(rcombined) \(nok)")
  }
}

final class Instantiator<N:Node> : Substitution, Equatable {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N? {
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  convenience
  init(dictionaryLiteral elements: (N, N)...) {
    self.init()
    for (key, value) in elements {
      self.storage[key] = value
    }
  }

  convenience
  init(dictionary: [N:N]) {
    self.init()
    self.storage = dictionary
  }

  func makeIterator() -> DictionaryIterator<N, N> {
    return storage.makeIterator()
  }

  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "\(type(of:self)) {\(pairs)}"
  }
}

func ==<N:Node>(lhs:Instantiator<N>, rhs:Instantiator<N>) -> Bool {
  return lhs.storage == rhs.storage
}
