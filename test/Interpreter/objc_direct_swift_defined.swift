// End-to-end test: Swift @objcDirect methods called from ObjC.
//
// RUN: %empty-directory(%t)
//
// Build Swift module with @objcDirect methods and generate ObjC header.
// RUN: %target-build-swift -emit-library -emit-module -emit-objc-header -emit-objc-header-path %t/ObjCDirectTest-Swift.h -module-name ObjCDirectTest %s -o %t/libObjCDirectTest.dylib
//
// Build ObjC caller that imports the generated header.
// RUN: %target-clang %S/Inputs/objc_direct_swift_defined_caller.m -I %t -c -o %t/caller.o -fobjc-arc -fobjc-direct-precondition-thunk
//
// Link and run.
// RUN: %target-build-swift %t/caller.o -L%t -lObjCDirectTest -o %t/a.out
// RUN: %target-codesign %t/a.out
// RUN: %target-run %t/a.out | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: objc_interop

import Foundation

public class Calculator: NSObject {
  private var _value: Int = 0

  @objcDirect public final func add(_ n: Int) -> Int {
    _value += n
    return _value
  }

  @objcDirect public final func reset() {
    _value = 0
  }

  @objcDirect public final func getValue() -> Int {
    return _value
  }

  @objcDirect public init(initialValue: Int) {
    _value = initialValue
    super.init()
  }
}

// CHECK: init: 10
// CHECK: add 5: 15
// CHECK: add 3: 18
// CHECK: reset
// CHECK: getValue: 0
