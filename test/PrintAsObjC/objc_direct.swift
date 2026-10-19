// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// The generated header annotates direct declarations, so Objective-C callers
// compile a direct call rather than a message send to a missing selector.

// RUN: %empty-directory(%t)

// FIXME: BEGIN -enable-source-import hackaround
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t %S/../Inputs/clang-importer-sdk/swift-modules/ObjectiveC.swift -disable-objc-attr-requires-foundation-module
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t  %S/../Inputs/clang-importer-sdk/swift-modules/CoreGraphics.swift
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t  %S/../Inputs/clang-importer-sdk/swift-modules/Foundation.swift
// FIXME: END -enable-source-import hackaround

// RUN: %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -I %S/Inputs/custom-modules -o %t %s -enable-experimental-feature ObjCDirect -disable-objc-attr-requires-foundation-module
// RUN: %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -parse-as-library %t/objc_direct.swiftmodule -typecheck -enable-experimental-feature ObjCDirect -emit-objc-header-path %t/objc_direct.h -import-objc-header %S/../Inputs/empty.h -disable-objc-attr-requires-foundation-module
// RUN: %FileCheck %s --input-file %t/objc_direct.h

import ObjectiveC

// The macros are guarded on __has_attribute so the header stays usable with a
// compiler that lacks objc_direct.
// CHECK: # if __has_attribute(objc_direct)
// CHECK-NEXT: #  define SWIFT_OBJC_DIRECT __attribute__((objc_direct))
// CHECK-NEXT: # else
// CHECK-NEXT: #  define SWIFT_OBJC_DIRECT
// CHECK-NEXT: # endif

// A property attribute cannot be spelled with __attribute__, so a property
// needs its own macro. It carries the trailing comma so that it can lead the
// attribute list and still leave valid syntax behind when it expands to
// nothing.
// CHECK: # if __has_attribute(objc_direct)
// CHECK-NEXT: #  define SWIFT_OBJC_DIRECT_PROPERTY direct,
// CHECK-NEXT: # else
// CHECK-NEXT: #  define SWIFT_OBJC_DIRECT_PROPERTY
// CHECK-NEXT: # endif

// CHECK-LABEL: @interface DirectMethodClass
// CHECK: - (NSInteger)directMethod SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
// Control: the plain @objc method is not annotated.
// CHECK-NOT: SWIFT_OBJC_DIRECT
// CHECK: - (void)normalMethod;
// CHECK: @end
public class DirectMethodClass: NSObject {
  @objcDirect public final func directMethod() -> Int { return 42 }
  @objc public func normalMethod() {}
}

// CHECK-LABEL: @interface DirectStorageClass
// CHECK-DAG: @property (SWIFT_OBJC_DIRECT_PROPERTY nonatomic){{.*}}directProperty;
// A subscript needs no new spelling: its accessors are printed as methods.
// CHECK-DAG: - (NSInteger)objectAtIndexedSubscript:{{.*}}SWIFT_OBJC_DIRECT;
// Control: a bare 'nonatomic', no macro.
// CHECK-DAG: @property (nonatomic){{.*}}normalProperty;
// CHECK: @end
public class DirectStorageClass: NSObject {
  @objcDirect public var directProperty: Int = 0
  @objcDirect public subscript(i: Int) -> Int { i }
  @objc public var normalProperty: Int = 0
}
