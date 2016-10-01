
import Foundation

struct Debug {

  fileprivate static let dateFormatter: DateFormatter = {
    let _formatter = DateFormatter()
    _formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return _formatter
  }()

  static func print(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
      let prefix = dateFormatter.string(from: NSDate() as Date) + " \(file.typeName).\(function):[\(line)]"
      let content = items.map { "\($0)" } .joined(separator: separator)
      Swift.print("\(prefix) \(content)\n", terminator: terminator)
    #endif
  }

}

extension String {

  var typeName: String {
    return lastPathComponent.stringByDeletingPathExtension
  }

  fileprivate var lastPathComponent: String {
    return (self as NSString).lastPathComponent
  }

  fileprivate var stringByDeletingPathExtension: String {
    return (self as NSString).deletingPathExtension
  }

}
