struct Config {
  static var filePath : FilePath? {
    var path : FilePath?
    switch Process.name {
      case "n/a":
        path = "Config/xctest.default"
      default:
        path = "Config/default.default"

    }
    guard let p = path where p.isAccessible else {
      print(path)
      return nil
    }

    return p

  }

}
