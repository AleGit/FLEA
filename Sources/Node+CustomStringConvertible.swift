// default implementations of 'CustomStringConvertible' and ''
extension Node {
  var debugDescription : String {
    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return "\(self.symbol)"
    }
    let tuple = nodes.map{ $0 }.joined(separator:",")
    return "\(self.symbol)(\(tuple))"
  }

  // var descritpion : String {
  //   return debugDescription
  // }
}

extension Node where Symbol : CustomDebugStringConvertible {
  var debugDescription : String {
    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return "\(self.symbol.debugDescription)"
    }
    let tuple = nodes.map{ "\($0)" }.joined(separator:",")
    return "\(self.symbol.debugDescription)(\(tuple))"
  }
}

extension Node where Symbol == String {
  var defaultDescription : String {
    guard let nodes = self.nodes?.map({"\($0)"})
    where nodes.count > 0
    else {
      return self.symbol
    }
    let tuple = nodes.map{ "\($0)" }.joined(separator:",")
    return "\(self.symbol)(\(tuple))"
  }
}

extension Node where Symbol == Tptp.Symbol {
  var defaultDescription : String {

      guard let nodes = self.nodes?.map({$0.description})
      where nodes.count > 0
      else {
        return "\(self.symbol.symbol)"
      }
      let tuple = nodes.map{ "\($0)" }.joined(separator:",")
      return "\(self.symbol.symbol)(\(tuple))"
    }

  }
