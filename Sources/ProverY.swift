import Foundation
import CYices

final class ProverY<N:Node>: Prover
where N:SymbolStringTyped {
    /// keep a history of read files
    var files = Array<(String, URL, Int, Int)>()

    /// all clauses from all read files
    var clauses: Array<(String, Tptp.Role, N)>

    fileprivate var insuredClauses: Dictionary<Int, Yices.Tuple>
    fileprivate var selectedLiteralIndices: Dictionary<Int, Int>
    fileprivate var selectedLiteralsTrie = TrieClass<SymHop<N.Symbol>, Int>()

    fileprivate var deadline: AbsoluteTime = 0.0
    fileprivate var context = Yices.Context()

    fileprivate let wildcardSymbol = N.symbolize(string:"*", type:.variable)



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

        insuredClauses = Dictionary<Int, Yices.Tuple>(minimumCapacity: clauses.count * 4)
        selectedLiteralIndices = Dictionary<Int, Int>(minimumCapacity: clauses.count * 4)

    }

    // simplest selection funciton
    func selectClauseIndex () -> Int? {
        guard insuredClauses.count <= clauses.count else { return nil }
        return insuredClauses.count
    }
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


    /// Process next clause, i.e. encode and assert clause with Yices, returns
    /// - false if
    ///     - no unprocessed clause was available, or
    ///     - context is not satifaible anymore
    /// - true otherwise
    private func processNextClause() -> Bool {
        guard let clauseIndex = selectClauseIndex(), clauseIndex < clauses.count else {
            Syslog.error(condition: { insuredClauses.count != clauses.count }) {
                "Just \(insuredClauses.count) of \(clauses.count) clauses were processed." }

            Syslog.notice(condition: { insuredClauses.count == clauses.count }) {
                "All \(clauses.count) clauses were processed." }

            return false
        }

        Syslog.error(condition: { insuredClauses[clauseIndex] != nil }) {
            "clause #\(clauseIndex) \(insuredClauses[clauseIndex])! already insured." }

        insuredClauses[clauseIndex] = context.insure(clause: clauses[clauseIndex].2)

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
            }
        ) {
            "Clashings do not match \(message)"
        }
    }

    private func findConflicts(clauseIndex: Int) {
        let clause = clauses[clauseIndex].2.appending(suffix:clauseIndex)

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

        Syslog.error(condition: { clashings.contains(clauseIndex)}) {
            "Clause \(clauseIndex).\(literalIndex) \(clause) MUST NOT clash with itself."
        }

        Syslog.debug {
            "Clashings for clause \(clauseIndex).\(literalIndex) \(clause): ".appending(
            "\(clashings.map { ($0,selectedLiteralIndices[$0]!)})")
        }

    }

    private func updateSelectedLiteralIndices() {

        guard let model = Yices.Model(context: context) else {
            Syslog.error { "No model!?"}
            return
        }

        for (clauseIndex, yicesTuple) in insuredClauses {
            let (_, yicesLiterals, _) = yicesTuple
            guard let selectedLiteralIndex = selectedLiteralIndices[clauseIndex] else {
                // no previously selected literal

                selectedLiteralIndices[clauseIndex] = model.selectIndex(literals: yicesLiterals)

                updateSelectedLiteralTrie(clauseIndex: clauseIndex)

                continue
            }

            if model.implies(formula: yicesLiterals[selectedLiteralIndex]) {
                // literal still holds, no need to update selected literal trie
                continue
            }

            // literal does not hold anymore

            selectedLiteralIndices[clauseIndex] = model.selectIndex(literals: yicesLiterals)

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
