import Foundation

/// The implemented procedure has the following bug:
/// - it searches for clashing literals of the selected literal of the selected clause and may saturate too fast
/// - Example
///     1: p(a)|q(X)
///     2: p(a)|~q(a)
///     3: ~p(a)
///     assert 1: -> 1:p(a) search for clashes in { }
///     assert 2: -> 2:p(a) search for clashes in { p(a) }
///     assert 3: -> 3:~p(a) - forces reselection in 1: and 2: - search for clashes in { 1:q(X), 2:~q(a) }, saturated
///     missing:

/// A instantiation-based prover that uses yices as satisfiablity checker modulo QF_EUF
/// quantifier free, equalitiy, uninterpreted functions
final class ProverY<N:Node, C:LogicContext>: Prover
where N:SymbolStringTyped {
    /// keep a history of read files
    fileprivate var files = Array<(String, URL, Int, Int)>()

    /// all clauses from all read files
    fileprivate var clauses: Array<(String, Tptp.Role, N)>

    fileprivate var processedClauseIndices: Set<Int>
    fileprivate let initialClauseCount: Int

    /// [ Int : (term_t, [term_t], [term_t]) ]
    fileprivate var insuredClauses: Dictionary<Int, C.Tuple>

    fileprivate var selectedLiteralIndices: Dictionary<Int, Int>

    /// maps selected literals to clause indices
    fileprivate var selectedLiteralsTrie = TrieClass<SymHop<N.Symbol>, Int>()

    // maps literals to clause indices
    fileprivate var variantsTrie = TrieClass<N.Symbol, Int>()

    fileprivate var deadline: AbsoluteTime = 0.0
    fileprivate var context = C()

    fileprivate let wildcardSymbol = N.symbolize(string:"*", type:.variable)

    var fileCount: Int { return files.count }
    var clauseCount: Int { return clauses.count }

    var insuredClausesCount: Int {
        return insuredClauses.count
    }

    /// Initialize a prover with a problem, read the problem file and axiom files.
    init?(problem name: String) {
        Syslog.info { "problem name = \(name)" }

        guard let (url, file) = ProverY.URLAndFile(problem: name) else { return nil }

        clauses = file.nameRoleClauseTriples()
        let includes = file.includeSelectionURLTriples(url: url)

        files.append((name, url, clauses.count, includes.count))

        for (name, list, url) in includes {
            guard let axioms: Array<(String, Tptp.Role, N)>
            = Tptp.File(url: url)?.nameRoleClauseTriples(
                predicate: { n, _ in list.isEmpty || Set(list).contains(n) }
            ) else {
                Syslog.error { "\(name) at \(url) was not read correctly." }
                return nil
            }
            clauses += axioms
            files.append((name, url, axioms.count, 0))
        }

        let capacity = clauses.count * 4
        processedClauseIndices = Set<Int>(minimumCapacity: capacity)
        initialClauseCount = clauses.count

        insuredClauses = Dictionary<Int, C.Tuple>(minimumCapacity: capacity)
        selectedLiteralIndices = Dictionary<Int, Int>(minimumCapacity: capacity)


    }

    // simplest selection funciton
    func selectClauseIndex () -> Int? {
        guard processedClauseIndices.count <= clauses.count else { return nil }
        return processedClauseIndices.count
    }
}

extension ProverY where N:SymbolTabulating {
    var isEquational: Bool { return N.symbols.isEquational }
}

extension ProverY {
    func run(timeout: TimeInterval) -> Bool? {

        deadline = AbsoluteTimeGetCurrent() + timeout

        guard let name = files.first?.0 else {
            Syslog.error { "Problem is empty" }
            return true // an empty problem is a theorem
        }
        Syslog.info { "\(timeout) s. '\(name)'" }

        while processNextClause() {
            let time = AbsoluteTimeGetCurrent()
            guard time < deadline else {
                Syslog.info { "\(timeout) s, expired by \(time - deadline) s. '\(name)'" }
                return nil
            }
        }

        Syslog.info { "\(deadline - AbsoluteTimeGetCurrent()) s remaining. '\(name)'" }

        // the loop has saturated
        return !context.isSatisfiable
    }


    /// Process next clause, i.e. encode and assert clause with SMT, returns
    /// - false if
    ///     - no unprocessed clause was available, or
    ///     - context is not satifaible anymore
    /// - true otherwise
    private func processNextClause() -> Bool {
        guard let clauseIndex = selectClauseIndex(), clauseIndex < clauses.count else {
            Syslog.error(condition: insuredClauses.count != clauses.count ) {
                "Just \(insuredClauses.count) of \(clauses.count) clauses were processed." }

            Syslog.notice(condition: insuredClauses.count == clauses.count ) {
                "All \(clauses.count) clauses were processed." }

            return false
        }

        /// mark a clause after processing
        defer { processedClauseIndices.insert(clauseIndex) }

        Syslog.error(condition: insuredClauses[clauseIndex] != nil ) {
            "clause #\(clauseIndex) \(insuredClauses[clauseIndex])! already insured." }

        let clause = clauses[clauseIndex]
        insuredClauses[clauseIndex] = context.ensure(clause: clause.2)

        // print("+", clauseIndex, clauses[clauseIndex].2)

        guard context.isSatisfiable else { return false }

        updateSelectedLiteralIndices()

        findConflicts(clauseIndex: clauseIndex)

        return true
    }

    // expensive, activate evaluation with
    // "ProverY.swift/checkConflictsLinearily(negatedLiteral:clashings:)" :: "debug"
    private func checkConflictsLinearily(negatedLiteral: N, clashings: Set<Int> = Set<Int>()) {
        var clauseIndices = clashings
        var message = "## ?!? ##"

        Syslog.debug(condition: {

            for (clauseIndex, literalIndex) in selectedLiteralIndices {
                let literal = clauses[clauseIndex].2.nodes![literalIndex]
                if (negatedLiteral =?= literal) != nil {
                    guard clauseIndices.remove(clauseIndex) != nil else {
                        message = "Clahing candidates do not contain clashing clause \(clauseIndex)"
                        assert(false, message)
                        return true
                    }
                }
            }

            if clauseIndices.count > 0 {
                // p(X,X) =?= p(a,b) would be found, but is not unifiable

                for clauseIndex in clauseIndices {
                    guard let literalIndex = selectedLiteralIndices[clauseIndex],
                    let literal = clauses[clauseIndex].2.nodes?[literalIndex] else {
                        assert(false,
                        "Clashing candidates contain missing or invalid clause \(clauseIndex)")
                        return true
                    }

                    if (literal =?= negatedLiteral) != nil {
                        assert(false, "Clasuse \(clauseIndex) should have been found linearily.")
                    }
                }
            }
            return false
            }()
        ) {
            "Clashings do not match \(message)"
        }
    }

    private func findConflicts(clauseIndex: Int) {
        // get ith clause and append suffix to variable names
        let clause = clauses[clauseIndex].2.appending(suffix:clauseIndex)

       let preorderTraversalSymbols = clause.preorderTraversalSymbols

       if let variants = variantsTrie.retrieve(from: preorderTraversalSymbols), variants.count > 0 {
           // print(clauseIndex, variants)
           // if variants where found, then the clause should be ignorable
           /*
           for variant in variants {
               print(clauseIndex, clause, preorderTraversalSymbols)
               print(variant, clauses[variant].2, clauses[variant].2.preorderTraversalSymbols)
               }
            return
            */
            // return
       }



        guard let nodes = clause.nodes,
        let literalIndex = selectedLiteralIndices[clauseIndex],
        (literalIndex < nodes.count) else {
            Syslog.error {
                "Clause #\(clauseIndex) does not exist or has no valid selected literal."
            }
            return
        }

        guard let negated = nodes[literalIndex].negating else {
            Syslog.error { "Literal \(clauseIndex).\(literalIndex) could not be negated." }
            return
        }

        guard let clashings = selectedLiteralsTrie.unifiables(paths: negated.leafPaths,
        wildcard: SymHop.symbol(wildcardSymbol)) else {
            Syslog.debug {
                "No clashings for clause \(clauseIndex).\(literalIndex) \(clause)"
            }

            checkConflictsLinearily(negatedLiteral:negated)

            return
        }

        checkConflictsLinearily(negatedLiteral:negated, clashings:clashings)

        Syslog.error(condition: clashings.contains(clauseIndex)) {
            "Clause \(clauseIndex).\(literalIndex) \(clause) MUST NOT clash with itself."
        }

        Syslog.debug {
            "Clashings for clause \(clauseIndex).\(literalIndex) \(clause): ".appending(
            "\(clashings.map { ($0, selectedLiteralIndices[$0]!)})")
        }

        deriveClauses(clause:clause, negatedLiteral:negated, clashings:clashings)

        variantsTrie.insert(clauseIndex, at: preorderTraversalSymbols)
    }

    private func deriveClauses(clause: N, negatedLiteral: N, clashings: Set<Int>) {
        for clauseIndex in clashings {
            let otherClause = clauses[clauseIndex].2
            guard let literalIndex = selectedLiteralIndices[clauseIndex],
            let literal = otherClause.nodes?[literalIndex] else {
                assert(false, "WTF")
                continue
            }

            guard let mgu = negatedLiteral =?= literal else {
                continue
            }

            // mgu is a proper instantiator, i.e. not a variable renaming.
            // Otherwise literals would clash on ground level.

            outer:
            for newClause in [clause * mgu, otherClause * mgu] {
                // if variants where found there should be no need to append the new clause

                if let variants = variantsTrie.retrieve(from: newClause.preorderTraversalSymbols),
                variants.count > 0 {
                    // print(clause, variants.map { clauses[$0].2 == clause ? 1 : 0})

                    /*
                    inner:
                    for variant in variants {
                        if variant < clauses.count && clauses[variant].2 == newClause {
                            continue outer
                        }

                    }
                    */
                    // should be ignorable
                    // continue
                }

                // print("...", clauses.count, newClause)
                clauses.append(("", .unknown, newClause))
            }





        }
    }

    private func updateSelectedLiteralIndices() {

        guard let model = context.model else {
            Syslog.error { "No model!?"}
            return
        }

        for (clauseIndex, smtTuple) in insuredClauses {
            let (_, smtLiterals, _) = smtTuple
            guard let selectedLiteralIndex = selectedLiteralIndices[clauseIndex] else {
                // no previously selected literal

                selectedLiteralIndices[clauseIndex] = model.selectIndex(literals: smtLiterals)

                updateSelectedLiteralTrie(clauseIndex: clauseIndex)

                continue
            }

            if model.implies(formula: smtLiterals[selectedLiteralIndex]) {
                // literal still holds, no need to update selected literal trie
                continue
            }

            // literal does not hold anymore

            selectedLiteralIndices[clauseIndex] = model.selectIndex(literals: smtLiterals)

            updateSelectedLiteralTrie(clauseIndex: clauseIndex,
            previousLiteralIndex: selectedLiteralIndex)
        }

    }

    private func updateSelectedLiteralTrie(clauseIndex: Int, previousLiteralIndex: Int? = nil) {
        guard clauseIndex < clauses.count,
        let nodes = clauses[clauseIndex].2.nodes else {
            Syslog.error { "Clause #\(clauseIndex) does not exist or has no nodes."}
            return
        }

        if let literalIndex = previousLiteralIndex {
            // remove literal paths from trie

            for path in nodes[literalIndex].leafPaths {
                guard let removedClauseIndex = selectedLiteralsTrie.remove(clauseIndex, at:path),
                removedClauseIndex == clauseIndex else {
                    Syslog.error { "\(literalIndex) was not removed at \(path)." }
                    continue
                }
            }
        }

        guard let literalIndex = selectedLiteralIndices[clauseIndex] else {
            Syslog.error { "No literal could be selected." }
            return
        }

        // insert literal paths into trie

        for path in nodes[literalIndex].leafPaths {
            selectedLiteralsTrie.insert(clauseIndex, at: path)
        }
    }
}
