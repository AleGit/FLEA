/*** This file could move to an own nodes module because Node.Symbol:Hashable only. ***/

/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*.
func =?= <N: Node, S: Substitution>(lhs:N, rhs:N) -> S?
where S.K == N, S.V == N, S.Iterator==DictionaryIterator<N, N> {
  Syslog.debug { "\(S.self) as unifier" }
  // delete
  if lhs == rhs {
    return S() // trivially unifiable, empty unifier
  }

  // variable elimination

  if lhs.isVariable {
    guard !rhs.variables.contains(lhs) else { return nil } // occur check
    return S(dictionary:[lhs:rhs])
  }
  if rhs.isVariable {
    guard !lhs.variables.contains(rhs) else { return nil } // occur check
    return S(dictionary:[rhs:lhs])
  }

  // both lhs and rhs are not variables

  // conflict

  guard lhs.symbol == rhs.symbol else { return nil }

  // decompositon

  guard var lnodes = lhs.nodes, var rnodes = rhs.nodes, lnodes.count == rnodes.count
  else { return nil }

  // signatures match

  var mgu = S()

  while lnodes.count > 0 {
    guard let unifier: S = (lnodes[0] =?= rnodes[0]) else { return nil }

    lnodes.removeFirst()
    rnodes.removeFirst()

    lnodes = lnodes.map { $0 * unifier }
    rnodes = rnodes.map { $0 * unifier }

    guard let concat = mgu * unifier else { return nil }

    mgu = concat
  }
  return mgu
}
