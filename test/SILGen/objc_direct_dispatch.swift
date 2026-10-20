// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// Swift-side dispatch for a direct member that is *not* written 'final'.

// RUN: %target-swift-emit-silgen -enable-experimental-feature ObjCDirect %s | %FileCheck %s

// A direct member gets no vtable slot, so emitting a dispatched reference to
// one fails SIL verification. The existing SILGen test covers only clang
// objc_direct declarations, which arrive already statically dispatched.

import Foundation

class NonFinalClass: NSObject {
  @objcDirect func directMethod() -> Int { 1 }

  @objcDirect var directProperty: Int = 0

  @objcDirect subscript(i: Int) -> Int { i }

  // Control: without it, the absences below would also hold if this test
  // simply emitted nothing.
  @objc func normalMethod() -> Int { 2 }
}

// CHECK-LABEL: sil {{.*}}callDirectMethod
// CHECK-NOT: class_method
// CHECK: } // end sil function
func callDirectMethod(_ c: NonFinalClass) -> Int {
  return c.directMethod()
}

// CHECK-LABEL: sil {{.*}}callDirectProperty
// CHECK-NOT: class_method
// CHECK: } // end sil function
func callDirectProperty(_ c: NonFinalClass) -> Int {
  c.directProperty = 1
  return c.directProperty
}

// CHECK-LABEL: sil {{.*}}callDirectSubscript
// CHECK-NOT: class_method
// CHECK: } // end sil function
func callDirectSubscript(_ c: NonFinalClass) -> Int {
  return c[0]
}

// CHECK-LABEL: sil {{.*}}callNormalMethod
// CHECK: class_method
// CHECK: } // end sil function
func callNormalMethod(_ c: NonFinalClass) -> Int {
  return c.normalMethod()
}

// 'super' has nothing to dispatch through either.
class Subclass: NonFinalClass {
  // CHECK-LABEL: sil {{.*}}Subclass{{.*}}callSuper
  // CHECK-NOT: super_method
  // CHECK: } // end sil function
  func callSuper() -> Int {
    return super.directMethod()
  }
}
