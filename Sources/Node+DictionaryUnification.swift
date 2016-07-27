/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*. (specialized for Dictionary)
func =?=<T:Node>(lhs:T, rhs:T) -> [T:T]? {
  // delete
  if lhs == rhs {
    return [T:T]() // trivially unifiable, empty unifier
  }

  // variable elimination

  if lhs.isVariable {
    guard !rhs.variables.contains(lhs) else { return nil } // occur check
    return [lhs:rhs]
  }
  if rhs.isVariable {
    guard !lhs.variables.contains(rhs) else { return nil } // occur check
    return [rhs:lhs]
  }

  // both lhs and rhs are not variables

  // conflict

  guard lhs.symbol == rhs.symbol else { return nil }

  // decompositon

  guard var lnodes = lhs.nodes, var rnodes = rhs.nodes
  where lnodes.count == rnodes.count
  else { return nil }

  // signatures match

  var mgu = [T:T]()

  while lnodes.count > 0 {
    guard let unifier = lnodes[0] =?= rnodes[0] else { return nil }

    lnodes.removeFirst()
    rnodes.removeFirst()

    lnodes = lnodes.map { $0 * unifier }
    rnodes = rnodes.map { $0 * unifier }

    guard let concat = mgu * unifier else { return nil }

    mgu = concat
  }
  return mgu
}
