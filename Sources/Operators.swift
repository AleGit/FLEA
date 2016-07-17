//  Copyright © 2016 Alexander Maringele. All rights reserved.

/// Construct unifier of left-hand side and right-hand side.
infix operator =?= {
associativity none
}

/// Is left-hand side a variant of righ-hand side? (unused)
infix operator ~~ {
associativity none
precedence 130
}

/// Construct unifier for clashing literals
infix operator ~?= {
associativity none
}

/// `t⊥` substitutes all veriables in `t` with constant `⊥`.
postfix operator ⊥ { }


infix operator ≈≈ {
associativity none
}

infix operator !≈ {
associativity none
}
