// RUN: %target-swift-frontend -emit-ir %s | %FileCheck %s
// REQUIRES: objc_interop

import Foundation

class Foo: NSObject {
  // Instance method
  @objcDirect final func bar() -> Int { return 42 }

  // Class method
  @objcDirect final class func classMethod() -> Int { return 1 }

  // Method with custom ObjC selector
  @objc(doSomethingWith:and:)
  @objcDirect final func doSomething(x: Int, y: Int) -> Int { return x + y }

  // Init
  @objcDirect init(value: Int) { super.init() }
}

// CHECK-DAG: define {{.*}} @"-[Foo bar]D"
// CHECK-DAG: define {{.*}} @"+[Foo classMethod]D"
// CHECK-DAG: define {{.*}} @"-[Foo doSomethingWith:and:]D"
// CHECK-DAG: define {{.*}} @"-[Foo initWithValue:]D"
