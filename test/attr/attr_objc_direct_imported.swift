// REQUIRES: objc_interop

// Without the feature, neither #selector nor #keyPath reports an imported
// direct declaration; attr_objc_direct_imported_enabled.swift is the same
// imports with the feature on.

// RUN: %target-typecheck-verify-swift -import-objc-header %S/../Inputs/objc_direct.h

import Foundation

func nameOnlyUses(_ bar: Bar) {
  _ = NSStringFromSelector(#selector(getter: Bar.directProperty))
  _ = NSStringFromSelector(#selector(Bar.directMethod))
}

func selectorReferences() -> [Selector] {
  return [
    #selector(Bar.directMethod),
    #selector(Bar.directClassMethod),
    #selector(getter: Bar.directProperty),
  ]
}

// objc_direct_members category.
func fromDirectMembersCategory() {
  _ = #selector(Bar.directMethod2)
  _ = #selector(getter: Bar.directProperty2)
}

func keyPaths() -> [String] {
  return [
    #keyPath(Bar.directProperty),
    #keyPath(Bar.directProperty2),
  ]
}
