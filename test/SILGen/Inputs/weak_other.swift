public struct Flags {
  public func asBoolean() -> Bool { return true }
}

public protocol Router : AnyObject {

}

extension Router {
  public var flags: Flags { return Flags() }
}

public protocol Environment : AnyObject {
  var router: Router { get }
}

open class UI {
  open unowned let environment: Environment

  init(e: Environment) {
    environment = e
  }
}
