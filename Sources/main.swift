import Foundation

print(Process.arguments)

// Demo.demo()

print("")

let nX1 = Sample.Node(symbol:"X", nodes:nil)
let nY1 = Sample.Node(symbol:"Y", nodes:nil)
let nY2 = Sample.Node(symbol:"Y", nodes:nil)
let nX2 = Sample.Node(symbol:"X", nodes:nil)

print("nX1 == nX1", nX1 == nX1)
print("nX1 == nY1", nX1 == nY1)
print("nX1 == nX2", nX1 == nX2)
print("nX1 == nY2", nX1 == nY2)

print("")

print("nX1 === nX1", nX1 === nX1)
print("nX1 === nY1", nX1 === nY1)
print("nX1 === nX2", nX1 === nX2)
print("nX1 === nY2", nX1 === nY2)

print("")

let snX1 = Sample.SharingNode(symbol:"X", nodes:nil)
let snY1 = Sample.SharingNode(symbol:"Y", nodes:nil)
let snY2 = Sample.SharingNode(symbol:"Y", nodes:nil)
let snX2 = Sample.SharingNode(symbol:"X", nodes:nil)

print("")

print("snX1 == snX1", snX1 == snX1)
print("snX1 == snY1", snX1 == snY1)
print("snX1 == snX2", snX1 == snX2)
print("snX1 == snY2", snX1 == snY2)

print("")

print("snX1 === snX1", snX1 === snX1)
print("snX1 === snY1", snX1 === snY1)
print("snX1 === snX2", snX1 === snX2)
print("snX1 === snY2", snX1 === snY2)

print(Sample.SharingNode.sharedNodes.count)
