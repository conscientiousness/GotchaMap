
import Foundation

struct Debug {

  private static let dateFormatter: NSDateFormatter = {
    let _formatter = NSDateFormatter()
    _formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return _formatter
  }()

  static func print(items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
      let prefix = dateFormatter.stringFromDate(NSDate()) + " \(file.typeName).\(function):[\(line)]"
      let content = items.map { "\($0)" } .joinWithSeparator(separator)
      Swift.print("\(prefix) \(content)\n", terminator: terminator)
    #endif
  }

}

extension String {

  var typeName: String {
    return lastPathComponent.stringByDeletingPathExtension
  }

  private var lastPathComponent: String {
    return (self as NSString).lastPathComponent
  }

  private var stringByDeletingPathExtension: String {
    return (self as NSString).stringByDeletingPathExtension
  }

}
