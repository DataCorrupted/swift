// RUN: %target-swift-frontend -emit-ir %s | %FileCheck %s
// REQUIRES: objc_interop

import Foundation

class MyClass: NSObject {
  @objcDirect final func directMethod() -> Int { return 42 }
  @objc final func normalObjcMethod() -> Int { return 1 }
}

// @objcDirect should produce a Direct ABI symbol with external linkage.
// CHECK-DAG: define hidden swiftcc {{.*}} @"-[MyClass directMethod]D"

// Normal @objc should produce a Swift-mangled symbol.
// CHECK-DAG: define {{.*}} @"$s{{.*}}17normalObjcMethod{{.*}}"
