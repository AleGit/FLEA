

extension Demo {
  struct Unification {
    static func demo() {

      // let nodes : [Tptp.Node] = demoCreateNodes()

      let X = Tptp.Node(variable: "X")
      let Y = Tptp.Node(variable: "Y")
      let Z = Tptp.Node(variable: "Z")

      let a = Tptp.Node(constant: "a")
      let b = Tptp.Node(constant: "a")

      let fXY = Tptp.Node(symbol: "f", nodes:[X,Y])

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
    }
  }
}
