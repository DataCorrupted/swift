// RUN: %target-typecheck-verify-swift

import Foundation

class SwiftClass {
  @objcDirect
  final func foo() { return }
  // expected-error@-2 {{@objcDirect cannot be used without @objc or @objcMembers}}
}

class NotObjCClassWObjCMethod {
  @objc @objcDirect
  final func foo() { return }
}

@objc
class ObjCDirectClass: NSObject {
  @objc @objcDirect
  final func direct() { return }

  @objcDirect
  final func anotherDirect() { return }
  // expected-error@-2 {{@objcDirect cannot be used without @objc or @objcMembers}}

  @objc @objcDirect
  final func objCDirectWithParams(x: Int, y: String) { return }

  @objc(RenamedRandomMethod) @objcDirect
  final func randomMethod() { return }
  // expected-error@-2 {{@objcDirect used with @objc with a name argument is not supported}}

  @objc @objcDirect
  static func staticAnswer() -> Int { return 42; }

  @objc @objcDirect
  func nonFinalMethod() { return }
  // expected-error@-2 {{@objcDirect can only be applied on final methods}}
}

extension ObjCDirectClass {
  @objc @objcDirect
  final func extendedDirect() { return }
}

extension ObjCDirectClass {
  @objc
  func dynamicParentDirectChild() { return }
  // expected-note@-1 {{overridden declaration is here}}
}

class SubObjcDirectClass : ObjCDirectClass {
  @objcDirect
  final func foo() { return }
  // expected-error@-2 {{@objcDirect cannot be used without @objc or @objcMembers}}

  @objc @objcDirect
  override final func dynamicParentDirectChild() { return }
  // expected-error@-1 {{methods that override superclass methods cannot be declared @objcDirect}}
}

@objc
protocol DirectBark {
  @objc @objcDirect
  func bark();
  // expected-error@-2 {{@objcDirect cannot be applied to methods declared in a protocol}}
}

// TODO: Should this be an error?
@objc
protocol Bark {
  func bark();
}

class Dog : Bark{
  @objc @objcDirect
  final func bark() { return }
}
