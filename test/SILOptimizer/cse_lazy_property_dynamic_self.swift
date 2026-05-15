// RUN: %target-swift-frontend -Osize -wmo -emit-sil -primary-file %s -module-name=test -o /dev/null
//
// Regression test: CSE must not inline a `lazy var` getter that binds dynamic
// Self into a function (e.g. an escaping closure) that has no self-metadata
// parameter. Without the guard in `CSE::processLazyPropertyGetters`, the
// inliner produces SIL whose first use of self-metadata asserts in
// `SILFunction::getDynamicSelfMetadata()`:
//
//   Assertion `hasDynamicSelfMetadata() && "This method can only be called if
//   the SILFunction has a self-metadata parameter"' failed.
//   While running pass SILFunctionTransform "CSE"
//   While inlining SIL function for getter for lazyButton
//
// Mirrors the existing guard in PerformanceInlinerUtils.cpp's
// getEligibleFunction().
//
// rdar://N/A — see swiftlang/swift#<TBD>.

// REQUIRES: OS=ios
// REQUIRES: objc_interop
// REQUIRES: swift_in_compiler

import UIKit

public final class Repro: UIViewController {
    // The static method called via `Self.make()` inside the lazy initializer
    // is what causes the synthesized getter's SIL to carry a `@thick Self.Type`
    // metadata parameter (so `mayBindDynamicSelf(getter)` returns true).
    private static func make() -> NSAttributedString { NSAttributedString() }

    // The `setAttributedTitle:` consumer is what keeps the metadata-binding
    // `apply` alive past DCE — without an `@objc` Cocoa consumer of the
    // `Self.make()` result, the metadata operand vanishes before CSE runs and
    // the bug never gets a chance to fire.
    private lazy var lazyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setAttributedTitle(Self.make(), for: .normal)
        return b
    }()

    // Two reads of `self.lazyButton` inside an escaping closure (which has no
    // self-metadata parameter) are what triggers CSE to attempt the unsafe
    // inline of the dominating getter call.
    public func trigger() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            _ = self.lazyButton
            _ = self.lazyButton
        }
    }
}
