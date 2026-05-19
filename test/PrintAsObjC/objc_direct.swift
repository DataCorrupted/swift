// REQUIRES: objc_interop

// RUN: %empty-directory(%t)

// FIXME: BEGIN -enable-source-import hackaround
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t %S/../Inputs/clang-importer-sdk/swift-modules/ObjectiveC.swift -disable-objc-attr-requires-foundation-module
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t  %S/../Inputs/clang-importer-sdk/swift-modules/CoreGraphics.swift
// RUN:  %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -o %t  %S/../Inputs/clang-importer-sdk/swift-modules/Foundation.swift
// FIXME: END -enable-source-import hackaround

// RUN: %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -emit-module -I %S/Inputs/custom-modules -o %t %s -disable-objc-attr-requires-foundation-module
// RUN: %target-swift-frontend(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -parse-as-library %t/objc_direct.swiftmodule -typecheck -emit-objc-header-path %t/objc_direct.h -import-objc-header %S/../Inputs/empty.h -disable-objc-attr-requires-foundation-module
// RUN: %FileCheck %s --input-file %t/objc_direct.h

import ObjectiveC

// CHECK-LABEL: @interface DirectMethodClass
// CHECK: - (NSInteger)directMethod SWIFT_OBJC_DIRECT
// CHECK: - (void)normalMethod;
// CHECK-NOT: SWIFT_OBJC_DIRECT
// CHECK: @end
public class DirectMethodClass: NSObject {
  @objcDirect public final func directMethod() -> Int { return 42 }
  @objc public func normalMethod() {}
}

// CHECK: SWIFT_OBJC_DIRECT
