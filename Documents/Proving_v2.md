# Instantiation based proving procedure

## Steps

1. Parse problem and axiom files
2. Build clause index structure to avoid variants of clauses
3. Build literal index structures to find clashing literals
4. Select clause, assert clause in yices context
5. If context is not satisfiable, return UNSAT
6. Get model and select literals for processed and actual clauses
7. Search clashing literals for all newly selected literals (update literal index)
8. Derive new clauses D, check for redundancy
    - discard D if clause D exists where mgu(D,D') is renaming
    - discard D = A|B, if if clause B exists where mgu(B,B') is renaming
    - deactivate C' = D'|E' where mgu(D,D') is renaming

## Parsing

1. Read and parse main (problem) file
    - extract clauses
    - extract includes

2. Read and pars includes, i.e. axiom files
    - extract clauses
    - error if includes

## Index structures

### Clause Index

We want to ignore variants (unifiable by variable renaming) of allready processed clauses.

- p(X) is a variant of p(Y)
- p(X) is a variant of p(Y)|p(Y)
- p(X) is not a variant of p(Y)|p(Z)

We look at the following clauses:

1. p(X) | q(f(Y), Z)
2. p(Y) | q(f(Z), X)
3. q(f(Z), X) | p(Y)
4. p(X) | q(f(X,X))
5. p(X) | q(Y,Z)
6. p(X)

- { 1, 2, 3} are variants

- Clause preorder traversal index
    - |.p.•.q.f.•.• -> {1,2,4}, 3 is missing, 4 is not a variant (but unifiable by variable substitution)
    - |.q.f.•.•.p.• -> {3}, 1 and 2 are missing
    - |.p.•.q.•.• -> {5}
    - |.p.• -> {6}

    Syntactical candidate variants can be found easily by building a prefix tree.

    We get the following candidates:
    - 1 -> { 2, 4} instead of { 2, 3}
    - 2 -> { 1, 4} instead of { 1, 3}
    - 3 -> { } instead of { 1,2}
    - 4 -> { 1,2} instead of { }
    - 5 -> { }
    - 6 -> { }

- Literal preorder traversal index
    - p.• -> {1,2,3,4,5,6}
    - q.f.•.• -> {1,2,3,4}
    - q.•.• -> {5}

    Semantical candidate variants can be found easily by building a prefix tree and set intersections.

    The intersection of {1,2,3,4,5} and {1,2,3,4} yields { 1,2,3,4}
    The intersection of {1,2,3,4,5} and {5} yields { 5}
    The intersection of {1,2,3,5} and {5} yields { 5}

    By intersection we get the following candidates:

    - 1 -> { 2,3,4} instead of { 2,3}
    - 2 -> { 1,3,4} instead of { 1,3}
    - 3 -> { 1,2,4} instead of { 1,2}
    - 4 -> { 1,2,3} instead of { }
    - 5 -> { }
    - 6 -> { 1,2,3,4,5 } instead of { }


### Literal index

We want to find quickly clashing (selected) literals and their clauses.

- Literal path indexing

    - p.1.• -> { 1, 2, 3, 4, 5, 6 }
    - q.1.f.• -> { 1, 2, 3, 4 }
    - q.2.• -> { 1, 2, 3, 4, 5 }

    We find candidates for ~p(X) or ~p(f(X) with serach index p.1.• or p.1.f.•

```
p.1.•  p.1.a  p.1.F
p.1.•  p.1.•  p.1.•

p.1.a  p.1.a
p.1.b  p.1.f.
```

## The Given Clause and Pair Algorithms

Repeat
    1. decide a set S of inferences to make
    2. make all inferences in S and process the results
until a proof has been found.

The given clause algorithm selects a clause C and makes inferences using C and all clauses
previously selected as given clauses.

The pair algorithm selects a pair of clauses (not previously selected) and makes inferences
between those two clauses only.


[www.cs.unm.edu/~mccune/prover9/manual/Dec-2007/loop.html](https://www.cs.unm.edu/~mccune/prover9/manual/Dec-2007/loop.html)

The Inference Loop

The main loop for inferring and processing clauses and searching for a proof is sometimes called the given clause algorithm.
It operates mainly on the sos and usable lists.

While the sos list is not empty:

    1. Select a given clause from sos and move it to the usable list;
    2. Infer new clauses using the inference rules in effect;
       each new clause must have the given clause as one of its
       parents and members of the usable list as its other parents;
    3. process each new clause;
    4. append new clauses that pass the retention tests to the sos list.

end of while loop.

sos = set of support, passive




1. p(a) | q(a)
2. p(a) | ~q(X)
3. ~p(X)


- assert clause 1, p(a) is the selected literal
- assert clause 2, p(a) is the selected literal, does not clash with 1:p(a)
- assert clause 3, ~p(X) is the selected literal, clashes with 1:p(a), 2.p(a)
    - derive ~p(a), (others can be igonred)

4. ~p(a)

- assert ~p(a), (re)select literals
    - 1.q(a)   (changed)
    - 2.~q(X)  (changed)
    - 3.~p(X)  (unchanged)
    - 4.~p(a)  (new), clashes with no literal (bug 2016.10: satisfied)

    - bug: process selected literal from given clause
    - bugfix: process clauses with changed selected literals (includes the given clause)
    - 1.q(a) clashes with 2.~q(X)

5. p(a) | ~q(a)

6. assert, unsatisfiable core
    - p(a) | q(a)
    - ~p(a)
    - p(a) | ~q(a)








