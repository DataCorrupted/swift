// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// A direct property leaves both Objective-C metadata lists: no accessor
// selectors, and no property descriptor.

// RUN: %target-swift-frontend -emit-ir \
// RUN:   -enable-experimental-feature ObjCDirect %s \
// RUN:   | %FileCheck %s \
// RUN:     --implicit-check-not='L_selector_data(count)' \
// RUN:     --implicit-check-not='L_selector_data(setCount:)' \
// RUN:     --implicit-check-not='L_selector_data(shared)' \
// RUN:     --implicit-check-not='L_selector_data(objectAtIndexedSubscript:)' \
// RUN:     --implicit-check-not='L_selector_data(setObject:atIndexedSubscript:)' \
// RUN:     --implicit-check-not='_PROPERTIES_DirectProps'

// The _PROPERTIES_ global is emitted only for a non-empty list, so its absence
// is what shows every property of the class was dropped. Both classes carry
// @objc(Name) so these patterns match the printed names rather than the
// mangled _TtC form.

import Foundation

@objc(DirectProps)
public class DirectProps: NSObject {
  // Accessors mangle under their selector with the direct-ABI suffix, and take
  // no trailing _cmd -- which is what the single '(ptr %0)' asserts.
  // CHECK-DAG: define {{.*}}@"-[DirectProps count]D"(ptr %0)
  // CHECK-DAG: define {{.*}}@"-[DirectProps setCount:]D"(ptr %0, i64 %1)
  @objcDirect public var count: Int = 0

  // CHECK-DAG: define {{.*}}@"-[DirectProps readOnly]D"(ptr %0)
  @objcDirect public var readOnly: Int { 0 }

  // A type property mangles with '+'.
  // CHECK-DAG: define {{.*}}@"+[DirectProps shared]D"(ptr %0)
  @objcDirect public static var shared: Int { 0 }

  // CHECK-DAG: define {{.*}}@"-[DirectProps objectAtIndexedSubscript:]D"(ptr %0, i64 %1)
  // CHECK-DAG: define {{.*}}@"-[DirectProps setObject:atIndexedSubscript:]D"(ptr %0, i64 %1, i64 %2)
  @objcDirect public subscript(i: Int) -> Int {
    get { i }
    set {}
  }
}

// Control: without it, the absences above would also hold for a test that
// simply failed to emit anything.
@objc(NormalProps)
public class NormalProps: NSObject {
  // CHECK-DAG: @"\01L_selector_data(normalCount)"
  // CHECK-DAG: @"\01L_selector_data(setNormalCount:)"
  // CHECK-DAG: _PROPERTIES_NormalProps
  @objc public var normalCount: Int = 0
}
