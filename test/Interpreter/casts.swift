// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: objc_interop

import StdlibUnittest
import Foundation

// Make sure at the end of the file we run the tests.
defer { runAllTests() }

protocol P : AnyObject { }
protocol C : AnyObject { }

class Foo : NSObject {}

var Casts = TestSuite("Casts")

@inline(never)
func castit<ObjectType>(_ o: NSObject?, _ t: ObjectType.Type) -> ObjectType? {
  return o as? ObjectType
}

@inline(never)
func castitExistential<ObjectType>(_ o: C?, _ t: ObjectType.Type) -> ObjectType? {
  return o as? ObjectType
}

Casts.test("cast optional<nsobject> to protocol") {
  if let obj = castit(nil, P.self) {
    print("fail")
    expectUnreachable()
  } else {
    print("success")
  }
}

Casts.test("cast optional<nsobject> to protocol meta") {
  if let obj = castit(nil, P.Type.self) {
    print("fail")
    expectUnreachable()
  } else {
    print("success")
  }
}
Casts.test("cast optional<protocol> to protocol") {
  if let obj = castitExistential(nil, P.self) {
    print("fail")
    expectUnreachable()
  } else {
    print("success")
  }
}

Casts.test("cast optional<protocol> to class") {
  if let obj = castitExistential(nil, Foo.self) {
    print("fail")
    expectUnreachable()
  } else {
    print("success")
  }
}

Casts.test("cast optional<protocol> to protocol meta") {
  if let obj = castitExistential(nil, P.Type.self) {
    expectUnreachable()
    print("fail")
  } else {
    print("success")
  }
}

Casts.test("cast optional<protocol> to class meta") {
  if let obj = castitExistential(nil, Foo.Type.self) {
    expectUnreachable()
    print("fail")
  } else {
    print("success")
  }
}

@objc public class ParentType : NSObject {
  var a = LifetimeTracked(0)
}

public class ChildType : ParentType {
}

struct SwiftStructWrapper {
  var a = LifetimeTracked(0)
}

extension SwiftStructWrapper : _ObjectiveCBridgeable {
  typealias _ObjectiveCType = ParentType

  func _bridgeToObjectiveC() -> _ObjectiveCType {
    return ParentType()
  }

  static func _forceBridgeFromObjectiveC(
    _ source: _ObjectiveCType,
    result: inout Self?
  ) {}

  @discardableResult
  static func _conditionallyBridgeFromObjectiveC(
    _ source: _ObjectiveCType,
    result: inout Self?
  ) -> Bool { return false }

  @_effects(readonly)
  static func _unconditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType?)
  -> Self {
    return SwiftStructWrapper()
  }
}

Casts.test("testConditionalBridgedCastFromSwiftToNSObjectDerivedClass") {
  autoreleasepool {
    let s = SwiftStructWrapper()
    let z = s as? ChildType
    print(z)
  }
  expectEqual(0, LifetimeTracked.instances)
}
