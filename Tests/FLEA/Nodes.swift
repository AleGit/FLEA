

@testable import FLEA



let ok = "✅"
let nok = "❌"

final class SmartNode : FLEA.SmartNode {
  static var allNodes = WeakCollection<SmartNode>()

  var symbol = ""
  var nodes : [SmartNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}

final class SharingNode : FLEA.SharingNode {
  static var allNodes = Set<SharingNode>()

  var symbol = ""
  var nodes : [SharingNode]? = nil

  lazy var hashValue : Int = self.defaultHashValue
  lazy var description : String = self.defaultDescription

  deinit {
    print("\(#function) \(self)")
  }
}
