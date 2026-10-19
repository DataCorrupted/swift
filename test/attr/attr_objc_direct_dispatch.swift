// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// A direct method is absent from its class's Objective-C method list, so every
// construct that reaches a method by selector at runtime is rejected.

// RUN: %target-typecheck-verify-swift -enable-experimental-feature ObjCDirect

import Foundation

class DispatchConflicts: NSObject {
  // No 'final' here: the 'dynamic' rule runs first, so a wrong order would
  // report "must be final" instead.
  @objcDirect dynamic func dynamicMethod() {}
  // expected-error@-1 {{'@objcDirect' cannot be applied to a 'dynamic' instance method; 'dynamic' requires dispatch through the Objective-C runtime}}

  // Wired up by selector from a nib or storyboard, which the compiler never
  // sees.
  @objcDirect @IBAction func action(_ sender: Any) {}
  // expected-error@-1 {{'@objcDirect' cannot be applied to an '@IBAction' or '@IBSegueAction' method; the action is invoked by selector}}

  @objcDirect @IBSegueAction func segueAction(_ coder: NSCoder) -> Any? { return nil }
  // expected-error@-1 {{'@objcDirect' cannot be applied to an '@IBAction' or '@IBSegueAction' method; the action is invoked by selector}}

  // Control: none of the above applies, so this is accepted.
  @objcDirect final func plainDirect() {}
}

@objc protocol Greeter {
  func greet() // expected-note {{requirement 'greet()' declared here}}
  func wave()
}

class DirectGreeter: NSObject, Greeter {
  @objcDirect final func greet() {}
  // expected-error@-1 {{cannot satisfy a requirement of '@objc' protocol 'Greeter' because it is a direct method}}

  // Control: a normal @objc witness is unaffected.
  func wave() {}
}

// AnyObject dispatch excludes a direct method from the lookup rather than
// diagnosing it, matching what Clang-imported objc_direct already does.
//
// Known limitation: if some *other* visible type has a non-direct method of the
// same name, that one is found instead and the call compiles, then fails at
// runtime -- the ambient hazard of AnyObject dispatch, not one this attribute
// adds.
@objc class DirectOnly: NSObject {
  @objcDirect final func onlyDirect() -> Int { return 0 }
  @objc final func alsoNormal() -> Int { return 0 }
}

func anyObjectDispatch(_ x: AnyObject) {
  let _ = x.onlyDirect()
  // expected-error@-1 {{value of type 'AnyObject' has no member 'onlyDirect'}}

  // Control: the sibling @objc method is still reachable dynamically.
  let _ = x.alsoNormal()
}
