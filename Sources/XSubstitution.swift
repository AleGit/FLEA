

protocol Substitution : DictionaryLiteralConvertible, Sequence, CustomStringConvertible
{
  associatedtype K : Hashable
  associatedtype V

    subscript (key:K) -> V? { get set }

    func makeIterator() -> DictionaryIterator<K, V>

    init(dictionary:[K:V])
    // init(dictionary:[N.Symbol:N])
    // init(dictionary:[N.Symbol:N.Symbol])
    // init(array:[(N,N)])

    mutating func clean()

}

extension Dictionary : Substitution {
  init(dictionary:[Key:Value]) {
    self = dictionary
  }
  mutating func clean() {
    // nothing to do
  }
}
