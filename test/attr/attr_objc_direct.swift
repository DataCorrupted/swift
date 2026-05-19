// RUN: %target-typecheck-verify-swift
// REQUIRES: objc_interop

import Foundation

// MARK: - Valid uses

@objc class ValidClass: NSObject {
  @objcDirect final func directMethod() {}
  @objcDirect final func directMethodWithArgs(_ x: Int, y: String) -> Bool { return true }
  @objc @objcDirect final func explicitObjC() {}
  @objcDirect init(value: Int) { super.init() }
}

// MARK: - Not final

@objc class NotFinalClass: NSObject {
  @objcDirect func notFinal() {} // expected-error {{'@objcDirect' methods must be 'final' to prevent overriding}}
}

// MARK: - Protocol

@objc protocol MyProtocol {
  @objcDirect func protoMethod() // expected-error {{'@objcDirect' cannot be applied to protocol requirements}}
}

// MARK: - Private / fileprivate

@objc class AccessClass: NSObject {
  @objcDirect final private func privateMethod() {} // expected-error {{'private' or 'fileprivate' methods cannot be '@objcDirect'}}
  @objcDirect final fileprivate func fileprivateMethod() {} // expected-error {{'private' or 'fileprivate' methods cannot be '@objcDirect'}}
  @objcDirect final internal func internalMethod() {} // ok
  @objcDirect final public func publicMethod() {} // ok
}

// MARK: - Async

@objc class AsyncClass: NSObject {
  @objcDirect final func asyncMethod() async {} // expected-error {{'@objcDirect' is not supported with 'async' methods}}
}

// MARK: - Override

@objc class Base: NSObject {
  @objc func baseMethod() {}
}

@objc class Child: Base {
  @objcDirect final override func baseMethod() {} // expected-error {{'@objcDirect' methods cannot override superclass methods}}
}

// MARK: - Deinit

@objc class DeinitClass: NSObject {
  @objcDirect deinit {} // expected-error {{'@objcDirect' cannot be applied to 'deinit'}}
}

// MARK: - Required init

@objc class RequiredInitClass: NSObject {
  @objcDirect required init(x: Int) { super.init() } // expected-error {{'@objcDirect' cannot be applied to 'required' initializers}}
}

// MARK: - Init (allowed without final)

@objc class InitClass: NSObject {
  @objcDirect init(value: Int) { super.init() } // ok
}
