/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*. (specialized for Dictionary)
func =?=<N:Node>(lhs:N, rhs:N) -> [N:N]? {
  // delete
  if lhs == rhs {
    return [N:N]() // trivially unifiable, empty unifier
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

  var mgu = [N:N]()

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