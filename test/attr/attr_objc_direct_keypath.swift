// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// '#keyPath' naming a direct property is rejected; imported direct
// properties are covered by attr_objc_direct_imported_enabled.swift.

// RUN: %target-typecheck-verify-swift -enable-experimental-feature ObjCDirect

import Foundation

// Unlike every other rejection this attribute makes, this one does not fail
// loudly without the check: key-value coding falls back to the instance
// variable when it finds no accessor, and 'direct' removes the accessor but
// keeps the storage, so value(forKey:) would keep returning the right answer
// through a mechanism nobody asked for.
//
// The note attaches to the declaration, not the use site, so a property named
// by two key paths produces two notes on one line.

@objc class KeyPathTarget: NSObject {
  // expected-note@+1 2 {{key-value coding would silently read the instance variable}}
  @objcDirect var directProperty: Int = 0

  @objc var normalProperty: Int = 0
}

func formKeyPaths() {
  _ = #keyPath(KeyPathTarget.directProperty)
  // expected-error@-1 {{argument of '#keyPath' refers to property 'directProperty' that is direct}}

  // Control: a sibling @objc property keeps its accessors.
  _ = #keyPath(KeyPathTarget.normalProperty)
}

// The rejection follows the property through a multi-component path.
@objc class Outer: NSObject {
  @objc var inner: KeyPathTarget = KeyPathTarget()
}

func nestedKeyPath() {
  _ = #keyPath(Outer.inner.directProperty)
  // expected-error@-1 {{argument of '#keyPath' refers to property 'directProperty' that is direct}}

  _ = #keyPath(Outer.inner.normalProperty)
}
