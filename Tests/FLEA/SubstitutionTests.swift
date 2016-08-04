import XCTest

@testable import FLEA

public class SubstitutionTests : XCTestCase {
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

    XCTAssertEqual("\(X_a.dynamicType))","Instantiator<SmartNode>)")

    guard let lc = (X_a * Y_b), let lcombined = lc * Z_c else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc.description,lcombined.description,"\(XYZ_abc) ≠ \(lcombined)")

    guard let rc = (Y_b * Z_c), let rcombined = X_a * rc else {
      XCTFail("\(X_a) * \(Y_b) * \(Z_c) was not derived.")
      return
    }

    XCTAssertEqual(XYZ_abc, rcombined,"\(XYZ_abc) ≠ \(rcombined)")
  }
}

final class Instantiator<N:Node> : Substitution, Equatable {
// struct Instantiator<N:Node> : Substitution, Equatable {
  private(set) var storage = [N:N]()

  subscript(key:N) -> N? {
    get { return storage[key] }
    set { storage[key] = newValue }
  }

  convenience
  init(dictionaryLiteral elements: (N, N)...) {
    // print("\(#function):\(elements)")
    self.init()
    for (key, value) in elements {
      self.storage[key] = value
    }
  }

  convenience
  init(dictionary: [N:N]) {
    // print("\(#function):\(dictionary)")
    self.init()
    self.storage = dictionary
  }

  func makeIterator() -> DictionaryIterator<N, N> {
    return storage.makeIterator()
  }

  var description : String {
    let pairs = self.map { "\($0)->\($1)"  }.joined(separator:",")
    return "{\(pairs)}"
  }
}

func ==<N:Node>(lhs:Instantiator<N>, rhs:Instantiator<N>) -> Bool {
  if lhs.storage != rhs.storage {
    print(lhs.storage.dynamicType,rhs.storage.dynamicType)
    print(lhs.dynamicType, rhs.dynamicType)
    print("\(#function) \(lhs.storage) \(rhs.storage)")

    let lkeys = Set(lhs.storage.keys)
    let rkeys = Set(rhs.storage.keys)
    print(lkeys, lkeys == rkeys, rkeys)

    for key in lkeys {
      let lvalue = lhs[key]!
        let rvalue = rhs[key]!
        if lvalue != rvalue {
          print(key,lvalue,rvalue,lvalue == rvalue)

          print(lvalue.hashValue, rvalue.hashValue)
          print(lvalue.dynamicType, rvalue.dynamicType)
        }
    }

  }
  return lhs.storage == rhs.storage
}
