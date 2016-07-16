// default implementations of 'CustomStringConvertible'
extension Node {
  func defaultDescription() -> String {
    guard let nodes = self.nodes?.map({$0.description})
    where nodes.count > 0
    else {
      return "\(self.symbol)"
    }
    let tuple = nodes.map{ "\($0)" }.joined(separator:",")
    return "\(self.symbol)(\(tuple))"
  }
  var description : String {
    return defaultDescription()
  }
}
