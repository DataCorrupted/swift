// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// '-enable-implicit-dynamic' is mutually exclusive with the attribute, since it
// makes every eligible method 'dynamic'.

// RUN: %target-typecheck-verify-swift -enable-experimental-feature ObjCDirect -enable-implicit-dynamic

import Foundation

// Caught only because the rule asks isDynamic() rather than
// hasAttribute<DynamicAttr>(). Its own file, not a second RUN line on
// attr_objc_direct_dispatch.swift, because this rule fires first and masks the
// others.
class ImplicitlyDynamic: NSObject {
  @objcDirect final func method() {}
  // expected-error@-1 {{'@objcDirect' cannot be applied to a 'dynamic' instance method; 'dynamic' requires dispatch through the Objective-C runtime}}
}
