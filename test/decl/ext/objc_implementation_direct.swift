// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCImplementation
// REQUIRES: swift_feature_ObjCDirect

// RUN: %target-typecheck-verify-swift -verify-ignore-unrelated \
// RUN:   -import-objc-header %S/Inputs/objc_implementation_direct.h \
// RUN:   -enable-experimental-feature ObjCImplementation \
// RUN:   -enable-experimental-feature ObjCDirect \
// RUN:   -target %target-stable-abi-triple \
// RUN:   -Xcc -Wno-nullability-completeness

import Foundation

@objc @implementation extension DirectImplClass {
  @objcDirect func directMethod() -> Int32 { 0 }

  func plainMethod() {}

  func anotherDirectMethod() -> Int32 { 0 }
  // expected-error@-1 {{should be '@objcDirect'}}

  @objcDirect func anotherPlainMethod() {}
  // expected-error@-1 {{should not be '@objcDirect'}}

  // '@property (direct)' imports as a direct property.
  @objcDirect var directProperty: Int32 { get { 0 } set {} }

  var plainProperty: Int32 { get { 0 } set {} }

  var anotherDirectProperty: Int32 { get { 0 } set {} }
  // expected-error@-1 {{should be '@objcDirect'}}

  @objcDirect var anotherPlainProperty: Int32 { get { 0 } set {} }
  // expected-error@-1 {{should not be '@objcDirect'}}
}
