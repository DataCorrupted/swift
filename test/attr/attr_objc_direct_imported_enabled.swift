// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// With the feature on, #selector and #keyPath reject imported direct
// declarations too; attr_objc_direct_imported.swift is the feature-off case.

// Matched on the tail of each message: attr_objc_direct_selector.swift and
// attr_objc_direct_keypath.swift pin the full wording. The notes land on the
// imported declarations, out of buffer, hence -verify-ignore-unrelated.

// RUN: %target-typecheck-verify-swift -verify-ignore-unrelated -enable-experimental-feature ObjCDirect -import-objc-header %S/../Inputs/objc_direct.h

import Foundation

func nameOnlyUses(_ bar: Bar) {
  _ = NSStringFromSelector(#selector(getter: Bar.directProperty))
  // expected-error@-1 {{that is a direct method}}
  _ = NSStringFromSelector(#selector(Bar.directMethod))
  // expected-error@-1 {{that is a direct method}}
}

func selectorReferences() -> [Selector] {
  return [
    #selector(Bar.directMethod),
    // expected-error@-1 {{that is a direct method}}
    #selector(Bar.directClassMethod),
    // expected-error@-1 {{that is a direct method}}
    #selector(getter: Bar.directProperty),
    // expected-error@-1 {{that is a direct method}}
  ]
}

// objc_direct_members category.
func fromDirectMembersCategory() {
  _ = #selector(Bar.directMethod2)
  // expected-error@-1 {{that is a direct method}}
  _ = #selector(getter: Bar.directProperty2)
  // expected-error@-1 {{that is a direct method}}
}

func keyPaths() -> [String] {
  return [
    #keyPath(Bar.directProperty),
    // expected-error@-1 {{that is direct}}
    #keyPath(Bar.directProperty2),
    // expected-error@-1 {{that is direct}}
  ]
}
