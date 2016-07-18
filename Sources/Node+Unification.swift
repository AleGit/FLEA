/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*.
func =?=<T:Node>(lhs:T, rhs:T) -> [T:T]? {

  if lhs == rhs {
    return [T:T]() // trivially unifiable
  }
    //   assert(lhs != rhs, "terms are variable distinct, hence they cannot be equal")

    switch(lhs.isVariable,rhs.isVariable) {
    case (true, true) where lhs.symbol == rhs.symbol:
        return [T:T]() // empty substitution
    case (true, true):
        return [lhs:rhs] // variable renaming
    case (true,_):
        guard !rhs.variables.contains(lhs) else { return nil } // occur check
        return [lhs:rhs]
    case (_,true):
        guard !lhs.variables.contains(rhs) else { return nil }  // occur check
        return [rhs:lhs]
    case (_, _) where lhs.symbol == rhs.symbol:

        // f(s1,s2,s3) =?= f(t1,t2,t3)

        var mgu = [T:T]()

        guard var lnodes = lhs.nodes, var rnodes = rhs.nodes
            where lnodes.count == rnodes.count
            else { return nil }

        while lnodes.count > 0 {
            guard let unifier = lnodes[0] =?= rnodes[0] else { return nil }

            lnodes.removeFirst()
            rnodes.removeFirst()

            lnodes = lnodes.map { $0 * unifier }
            rnodes = rnodes.map { $0 * unifier }

            mgu *= unifier

            for (key,value) in unifier {
                if let term = mgu[key] where term != value  { return nil }
                mgu[key] = value

            }

        }

        let decomposition = zip(lhs.nodes!, rhs.nodes!)

        for (s,t) in decomposition {
            guard let unifier = s =?= t else { return nil }

            mgu *= unifier



        }


        return mgu

    case (_,_) where lhs.symbol == rhs.symbol:
        //        assert(lhs.symbol == "|", "\(lhs.symbol) must not be variadic (\(lhs.nodes!.count),\(rhs.nodes!.count)")
        return nil
    default:
        return nil
    }
}

func *=<T:Node>(lhs:inout [T:T], rhs:[T:T]) {
    for (key,value) in lhs {
        lhs[key] = value * rhs
    }
}
