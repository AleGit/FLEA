/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*.
func =?=<T:Node,S:Substitution where S.K == T, S.V == T,
S.Iterator==DictionaryIterator<T,T>>(lhs:T,rhs:T) -> S? {
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

  guard var lnodes = lhs.nodes, var rnodes = rhs.nodes
  where lnodes.count == rnodes.count
  else { return nil }

  // signatures match

  var mgu = S()

  while lnodes.count > 0 {
    guard let unifier : S = (lnodes[0] =?= rnodes[0]) else { return nil }

    lnodes.removeFirst()
    rnodes.removeFirst()

    lnodes = lnodes.map { $0 * unifier }
    rnodes = rnodes.map { $0 * unifier }

    guard let concat = mgu * unifier else { return nil }

    mgu = concat
  }
  return mgu
}
