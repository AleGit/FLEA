//  Copyright © 2016 Alexander Maringele. All rights reserved.

/*
 precedencegroup UnificationPrecedence {
 higherThan: AdditionPrecedence
 lowerThan: MultiplicationPrecedence
 }
 */

/// Construct unifier of left-hand side and right-hand side.
infix operator =?= // : UnificationPrecedence

/// Construct unifier for clashing literals (unused)
// infix operator ~?= : UnificationPrecedence

/// Is left-hand side a variant of righ-hand side? (unused)
// infix operator ~~ : ComparisonPrecedence

/// `t⊥` substitutes all veriables in `t` with constant `⊥`.
postfix operator ⊥

// infix operator ≈≈

// infix operator !≈
