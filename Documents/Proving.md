Procedure for *»Proving with Instances«*
===

Setting the stage
--

The prover builds up a repository of clauses.

- The prover reads a problem file.
  The problem file contains a sequence of inputs:

  - `include(file [,selection]).`: additionally input files (with axioms)
  - `cnf(name,role,clause [,annotations]).`: first order clauses
  - `fof(name,role,formula [,annotations]).`: arbitrary first order formulas *[unsupported]*

- The prover adds the first order clauses to its repository.

- The prover transforms the arbitrary first order formulas into  equi-satisfiable first order clauses and adds them to its repository. *[unsupported]*

- The prover reads the additionally files (if any) and adds the selected axioms to its clause repository.

State
--

The prover will maintain

- a growing repository of clauses
- a list of properties for each clause, e.g.

  - name from file or nil for derived clauses
  - role form file or ... for derived clauses
  - origin from file or clause (instantiation)
  - unprocessed -> processed
  - selected literal (can change after processing)
- a `yices` context

The Loop
--

As long as there is an unprocessed clause the prover ...
- selects an unprocessed clause (by a strategy)
- asserts the grounded selected clause in `yices` context
- checks the satisfiability of the context
  - if unsatisfiable the prover exits the loop
  - otherwise it gets a model from the context
- selects a literal from the clause by the model
- (reselects the literals of the processed clauses)
- searches for clashing selected literals in processed clauses
- creates (non-ground) instances of the clashing clauses and adds
  them to the repository (if no variants are in the repository)
- when all clashing literals are processed the selected clause is
  added to the processed clauses

### Indexing of selected literals

After a clause is processed its selected literal is put into the term index.
But the selected literal of already processed clauses could change
when the model changes through the assertion of subsequent clauses. 
This invalidates entries in the index.
There are two approaches:
- **synchronous**: After getting a new model run through all processed clauses and check if the selected literal still holds and update the index if necessary
- **lazy**: retrieve clashing literals, check if clashing literal still holds in model
  - if it holds, use it
  - if it does not hold, update index, check if newly selected
    literal clashes
  - **this will fail** so we stay with **synchronous**

### Avoiding clause variants

With `f(x) | g(y)` in the repository we do not want to add `g(z) | f(x) | h(y)` to the repository.
- check if their is a variant of a subset of its literals already in the repository
