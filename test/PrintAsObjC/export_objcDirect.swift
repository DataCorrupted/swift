// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend %s -c -emit-objc-header -emit-objc-header-path %t/%s.h
// RUN: %FileCheck %s --input-file %t/%s.h

// CHECK: #if !defined(SWIFT_OBJC_DIRECT)
// CHECK-NEXT: # define SWIFT_OBJC_DIRECT __attribute__((objc_direct))
// CHECK-NEXT: #endif

import Foundation

class ObjCDirectClass: NSObject {
  // CHECK: SWIFT_CLASS("_TtC17export_objcDirect15ObjCDirectClass")
  // CHECK-NEXT: @interface ObjCDirectClass : NSObject

  // CHECK-NEXT: - (NSInteger)returnOne SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  final func returnOne() -> Int { return 1 }

  // CHECK-NEXT: - (NSInteger)aPlusBWithInt:(NSInteger)int_ b:(NSInteger)b SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  final func aPlusB(int: Int, b: Int) -> Int { return int + b }

  // CHECK-NEXT: + (NSInteger)staticAnswer SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  static func staticAnswer() -> Int { return 42 }
  // CHECK-NEXT: - (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
  // CHECK-NEXT: @end
}

class SubObjcDirectClass : ObjCDirectClass {
  // CHECK: SWIFT_CLASS("_TtC17export_objcDirect18SubObjcDirectClass")
  // CHECK-NEXT: @interface SubObjcDirectClass : ObjCDirectClass

  // CHECK-NEXT: + (NSInteger)anotherAnswer SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  static func anotherAnswer() -> Int { return 41 }

  // CHECK-NEXT: - (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
  // CHECK-NEXT: @end
}
