// {"signature":"swift::rewriting::RequirementMachine::verify(swift::rewriting::MutableTerm const&) const"}
// RUN: not --crash %target-swift-frontend -typecheck %s
// REQUIRES: asserts
protocol a {
  typealias Index extension Collection where Self : a{b : Index} protocol a
