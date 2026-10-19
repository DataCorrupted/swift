// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// '#selector' naming a direct method is rejected; imported direct methods are
// covered by attr_objc_direct_imported_enabled.swift.

// RUN: %target-typecheck-verify-swift -enable-experimental-feature ObjCDirect

import Foundation

// The note attaches to the declaration, not the use site, so a method named by
// two '#selector' expressions produces two notes on one line.
@objc class SelectorTarget: NSObject {
  // expected-note@+1 2 {{a direct method is not added to its class's Objective-C method list}}
  @objcDirect final func directHandler() {}
  // expected-note@+1 {{a direct method is not added to its class's Objective-C method list}}
  @objcDirect public final func publicDirectHandler() {}

  @objc final func normalHandler() {}
}

func formSelectors(_ target: SelectorTarget) {
  _ = #selector(SelectorTarget.directHandler)
  // expected-error@-1 {{argument of '#selector' refers to instance method 'directHandler()' that is a direct method}}

  _ = #selector(SelectorTarget.publicDirectHandler)
  // expected-error@-1 {{argument of '#selector' refers to instance method 'publicDirectHandler()' that is a direct method}}

  // Through an instance reference, not just the type.
  _ = #selector(target.directHandler)
  // expected-error@-1 {{argument of '#selector' refers to instance method 'directHandler()' that is a direct method}}

  // Control: a sibling @objc method keeps its selector.
  _ = #selector(SelectorTarget.normalHandler)
}
