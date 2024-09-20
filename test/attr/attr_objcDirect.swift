// RUN: %target-typecheck-verify-swift
// REQUIRES: objc_interop

import Foundation

class Foo: NSObject {

  @objc
  func method(x: Any) -> Any { return x }

  @objc @objcDirect
  func indirectAny(x: NSObject) {} // expected-error{{type of the parameter cannot be represented in Objective-C}}


  @objcDirect
  func objcDirectOnly() { return }
}
