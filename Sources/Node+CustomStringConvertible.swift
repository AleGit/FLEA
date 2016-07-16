// default implementations of 'CustomStringConvertible'
extension Node {
  var debugDescription : String {
    guard let nodes = self.nodes?.map({$0.debugDescription})
    where nodes.count > 0
    else {
      return "\(self.symbol)"
    }
    let tuple = nodes.map{ "\($0)" }.joined(separator:",")
    return "\(self.symbol)(\(tuple))"
  }

  var description : String {
    return debugDescription
  }
}

extension Node where Symbol == String {
  var description : String {
    guard let nodes = self.nodes?.map({"\($0)"})
    where nodes.count > 0
    else {
      return self.symbol
    }
    let tuple = nodes.map{ "\($0)" }.joined(separator:",")
    return "\(self.symbol)(\(tuple))"
  }
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

extension Node where Symbol == Tptp.Symbol {
  var tptpDescription : String {

      guard let nodes = self.nodes?.map({$0.description})
      where nodes.count > 0
      else {
        return "\(self.symbol.symbol)"
      }
      let tuple = nodes.map{ "\($0)" }.joined(separator:",")
      return "\(self.symbol.symbol)(\(tuple))"
    }

  }