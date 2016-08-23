protocol Prover {
    func assert<N:Node>(
        name:String? = nil,
        role:String? = nil,
        clause:N) -> Bool {

    }
}

struct SimpleProver<N:Node> : Prover {
    func assert(clause:N) {
        return false
    }
}