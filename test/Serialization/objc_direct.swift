// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

/// Round-trip @objcDirect through a *binary* .swiftmodule, which carries it by
/// record code rather than by printing and re-parsing as the .swiftinterface in
/// test/ModuleInterface/objc_direct.swift does.
///
/// The oracle is witness_objc_direct, which can only be emitted if the
/// *deserialized* declaration still carries the attribute.

// RUN: %empty-directory(%t)
// RUN: split-file %s %t

/// Library with the attribute, emitted as a binary .swiftmodule.
// RUN: %target-swift-frontend -emit-module -o %t/DirectLib.swiftmodule \
// RUN:   -module-name DirectLib -enable-experimental-feature ObjCDirect \
// RUN:   %t/DirectLib.swift

/// The attribute survived: conforming the imported class in the client is
/// rejected.
// RUN: %target-swift-frontend -typecheck -verify -I %t \
// RUN:   -verify-additional-prefix direct- \
// RUN:   -enable-experimental-feature ObjCDirect %t/Client.swift

/// Negative control: the same library as plain @objc, where the error is
/// absent. The substitution replaces @objcDirect rather than deleting it, since
/// deleting it would also remove the implied @objc and fail for an unrelated
/// reason.
// RUN: %empty-directory(%t/plain)
// RUN: sed 's/@objcDirect/@objc/' %t/DirectLib.swift > %t/plain/DirectLib.swift
// RUN: %target-swift-frontend -emit-module -o %t/plain/DirectLib.swiftmodule \
// RUN:   -module-name DirectLib %t/plain/DirectLib.swift
// RUN: %target-swift-frontend -typecheck -verify -I %t/plain \
// RUN:   -enable-experimental-feature ObjCDirect %t/Client.swift

//--- DirectLib.swift

import Foundation

@objc public protocol Greeter {
  func greet()
}

@objc public class DirectGreeter: NSObject {
  @objcDirect public final func greet() {}
}

@objc public protocol Counter {
  var count: Int { get }
}

@objc public class DirectCounter: NSObject {
  @objcDirect public var count: Int = 0
}

//--- Client.swift

import DirectLib

/// Conformed in the client, so the witness is the deserialized greet().
extension DirectGreeter: Greeter {}
// expected-direct-error@-1 {{cannot satisfy a requirement of '@objc' protocol 'Greeter' because it is a direct method}}

/// The same round-trip on a VarDecl.
extension DirectCounter: Counter {}
// expected-direct-error@-1 {{cannot satisfy a requirement of '@objc' protocol 'Counter' because it is a direct method}}
