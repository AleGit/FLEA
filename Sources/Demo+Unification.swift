

extension Demo {
  struct Unification {
    static func demo() -> Int {

      // let nodes : [Tptp.Node] = demoCreateNodes()

      let X = Tptp.Node(v: "X")
      let Y = Tptp.Node(v: "Y")
      let Z = Tptp.Node(v: "Z")

      let a = Tptp.Node(c: "a")
      let b = Tptp.Node(c: "a")

      let fXY = Tptp.Node(f: "f", [X,Y])

      let fYX = fXY * [X:Y, Y:X]
      let fYZ = fXY * [X:Y, Y:Z]
      let fab = fXY * [X:a, Y:b]
      let ffabZ = fXY * [X:fab, Y:Z]

      let nodes = [ fXY, fYX, fYZ, fab, ffabZ ]

      for f in nodes {
        for g in nodes {
          guard let mgu = f =?= g else {
            print("\(f) =?= \(g) is not unifiable.")
            continue
          }
          print("\(f) =?= \(g) = \(mgu.description)")

        }
      }
      return nodes.count
    }
  }
}
