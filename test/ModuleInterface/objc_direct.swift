// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// @objcDirect is printed into the .swiftinterface, which therefore has to carry
// enough information to be rebuilt from.

// RUN: %empty-directory(%t)
// RUN: %target-swift-emit-module-interface(%t/Mod.swiftinterface) %s \
// RUN:   -module-name Mod -enable-experimental-feature ObjCDirect

// The interface records the feature and not the Clang flag.
// RUN: %FileCheck %s --input-file %t/Mod.swiftinterface \
// RUN:   --implicit-check-not='fobjc-direct-precondition-thunk'

// Rebuilding names neither on the command line, so everything has to come from
// the interface. This is why the attribute is gated on a Swift feature and not
// on Clang's -fobjc-direct-precondition-thunk: -Xcc is not a
// ModuleInterfaceOption and never reaches swift-module-flags, whereas
// -enable-experimental-feature does, and re-derives the Clang flag.
// RUN: %target-swift-typecheck-module-from-interface(%t/Mod.swiftinterface) \
// RUN:   -module-name Mod

// CHECK: swift-module-flags:{{.*}}-enable-experimental-feature ObjCDirect
// CHECK: @objcDirect{{.*}}func lookup()
// CHECK: @objcDirect{{.*}}var count:
// CHECK: @objcDirect{{.*}}subscript(

import Foundation

@objc public class Cache: NSObject {
  @objcDirect public final func lookup() {}
  @objcDirect public var count: Int = 0
  @objcDirect public subscript(i: Int) -> Int { i }
}
