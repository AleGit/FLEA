


func =?=<T:Node,S:Substitution where S.K == T, S.V == T>(lhs:T,rhs:T) -> S? {
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
    let x : S? = lnodes[0] =?= rnodes[0]
    guard let unifier : S = x else {
      return nil
    }

    lnodes.removeFirst()
    rnodes.removeFirst()

    lnodes = lnodes.map { $0 * unifier }
    rnodes = rnodes.map { $0 * unifier }


    guard let concat = mgu * unifier else { return nil }

    mgu = concat
  }
  return mgu

}