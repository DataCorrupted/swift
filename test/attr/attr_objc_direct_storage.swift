// REQUIRES: objc_interop
// REQUIRES: swift_feature_ObjCDirect

// Where '@objcDirect' is accepted and rejected on properties and subscripts,
// which share most of their rules with the methods in attr_objc_direct.swift.

// RUN: %target-typecheck-verify-swift -enable-experimental-feature ObjCDirect

import Foundation

class StorageClass: NSObject {
  @objcDirect var stored: Int = 0

  @objcDirect var computed: Int { get { 0 } set {} }

  @objcDirect var readOnly: Int { 0 }

  @objcDirect let constant: Int = 0

  @objc(renamedCount) @objcDirect var renamed: Int = 0

  @objcDirect subscript(i: Int) -> Int { get { i } set {} }

  @objcDirect subscript(key: NSString) -> NSString { NSString() }
}

// A getter that is direct while its setter is not has no Objective-C spelling,
// so the attribute goes on the storage and covers both accessors.
class AccessorClass: NSObject {
  var onGetter: Int {
    @objcDirect get { 0 }
    // expected-error@-1 {{apply it to the property, which makes both accessors direct}}
    set {}
  }

  var onSetter: Int {
    get { 0 }
    @objcDirect set {}
    // expected-error@-1 {{apply it to the property, which makes both accessors direct}}
  }

  subscript(i: Int) -> Int {
    @objcDirect get { i }
    // expected-error@-1 {{apply it to the subscript, which makes both accessors direct}}
    set {}
  }
}

// Including the 'dynamic' that '@NSManaged' implies.
class DynamicClass: NSObject {
  @objcDirect dynamic var explicitlyDynamic: Int = 0
  // expected-error@-1 {{'@objcDirect' cannot be applied to a 'dynamic' property}}

  @objcDirect @NSManaged var managed: NSString
  // expected-error@-1 {{'@objcDirect' cannot be applied to a 'dynamic' property}}
}

class AccessLevelClass: NSObject {
  @objcDirect private var hidden: Int = 0
  // expected-error@-1 {{a 'private' or 'fileprivate' property cannot be '@objcDirect'}}

  @objcDirect fileprivate subscript(i: Int) -> Int { i }
  // expected-error@-1 {{a 'private' or 'fileprivate' subscript cannot be '@objcDirect'}}
}

class Base: NSObject {
  @objc var overridable: Int = 0

  @objcDirect var notOverridable: Int = 0
  // expected-note@-1 {{overridden declaration is here}}

  @objcDirect subscript(i: Int) -> Int { i }
  // expected-note@-1 {{overridden declaration is here}}
}

class Derived: Base {
  @objcDirect override var overridable: Int { get { 0 } set {} }
  // expected-error@-1 {{an '@objcDirect' property cannot override a superclass declaration}}

  // The reverse direction, reported once against the storage rather than once
  // per accessor.
  override var notOverridable: Int { get { 0 } set {} }
  // expected-error@-1 {{cannot override property declared '@objcDirect'}}

  override subscript(i: Int) -> Int { 0 }
  // expected-error@-1 {{cannot override subscript declared '@objcDirect'}}
}

@objc protocol StorageProtocol {
  @objcDirect var requirement: Int { get }
  // expected-error@-1 {{'@objcDirect' cannot be applied to protocol requirements}}

  @objcDirect subscript(i: Int) -> Int { get }
  // expected-error@-1 {{'@objcDirect' cannot be applied to protocol requirements}}
}

class GenericClass<T>: NSObject {
  @objcDirect var inGeneric: Int = 0
  // expected-error@-1 {{'@objcDirect' cannot be applied to members of a generic class}}
}

struct SomeStruct {
  @objcDirect var structProperty: Int = 0
  // expected-error@-1 {{'@objcDirect' can only be applied to members of a class}}

  @objcDirect subscript(i: Int) -> Int { i }
  // expected-error@-1 {{'@objcDirect' can only be applied to members of a class}}
}

@objcDirect var globalProperty: Int = 0
// expected-error@-1 {{'@objcDirect' can only be applied to members of a class}}

// A direct property's accessors are not in the method list, so witnessing an
// '@objc' requirement would fail at every call through the protocol.
@objc protocol HasCount {
  var count: Int { get } // expected-note {{requirement 'count' declared here}}
  var size: Int { get }
}

class DirectCount: NSObject, HasCount {
  @objcDirect var count: Int = 0
  // expected-error@-1 {{cannot satisfy a requirement of '@objc' protocol 'HasCount'}}

  // Control: a normal @objc witness is unaffected.
  var size: Int = 0
}
