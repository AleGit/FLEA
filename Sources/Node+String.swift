// default implementations of 'CustomStringConvertible'
extension Node where Symbol == String {
  func tptpDescription() -> String {

    guard let nodes = self.nodes?.map({$0.description})
    where nodes.count > 0
    else {
      return self.symbol
    }

    let tuple = nodes.joined(separator:",")

    return "\(self.symbol)(\(tuple))"

  }

  var description : String {
    return tptpDescription()
  }



}
