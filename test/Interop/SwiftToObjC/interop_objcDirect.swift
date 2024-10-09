// REQUIRES: objc_interop
// RUN: %empty-directory(%t)
// RUN: split-file %s %t

// Generate the module
// RUN: %target-swiftc_driver %t/DirectModule.swift -c -emit-library -o %t/libDirectModule.dylib

// Generate the header
// RUN: %target-swiftc_driver %t/DirectModule.swift -emit-objc-header -emit-objc-header-path %t/DirectModule.h
// RUN: %FileCheck %s < %t/DirectModule.h -check-prefix=CHECK-HEADER

// Generate the use of the module and link it
// RUN: %target-clang %t/UseDirectModule.m %t/libDirectModule.dylib -fobjc-export-direct-methods -lobjc -o %t/executable

// Execute
// RUN: %t/executable | %FileCheck %s -check-prefix=CHECK-EXE-STDOUT

//--- DirectModule.swift
import Foundation

public class ObjCDirectClass: NSObject {
  // CHECK-HEADER: - (NSInteger)returnOne SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  public final func returnOne() -> Int { return 1 }

  // CHECK-HEADER: - (NSInteger)aPlusBWithInt:(NSInteger)int_ b:(NSInteger)b SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  public final func aPlusB(int: Int, b: Int) -> Int { return int + b }

  // CHECK-HEADER: + (NSInteger)staticAnswer SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  public static func staticAnswer() -> Int { return 42 }

  // CHECK-HEADER: + (NSInteger)staticAddWithA:(NSInteger)a b:(NSInteger)b SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  public static func staticAdd(a: Int, b: Int) -> Int { return a + b }
}

public class SubObjCDirectClass : ObjCDirectClass {
  // CHECK-HEADER: + (NSInteger)incorrectAnswer SWIFT_WARN_UNUSED_RESULT SWIFT_OBJC_DIRECT;
  @objc @objcDirect
  public static func incorrectAnswer() -> Int { return 41 }
}

//--- UseDirectModule.m
#include "DirectModule.h"

@interface Foo : NSObject
    - (int) returnOne __attribute__((objc_direct));
@end
@implementation Foo
- (int) returnOne {
    return 1;
}
@end

int main() {
    Foo* foo = [Foo alloc];
    int one = [foo returnOne];
    // CHECK-EXE-STDOUT: 1
    printf("%d\n", one);

    ObjCDirectClass* direct = [ObjCDirectClass alloc];
    one = [direct returnOne];
    // CHECK-EXE-STDOUT-NEXT: 1
    printf("%d\n", one);

    int staticAnswer = [ObjCDirectClass staticAnswer];
    // CHECK-EXE-STDOUT-NEXT: 42
    printf("%d\n", staticAnswer);

    int incorrectAnswer = [SubObjCDirectClass incorrectAnswer];
    // CHECK-EXE-STDOUT-NEXT: 41
    printf("%d\n", incorrectAnswer);

    SubObjCDirectClass* subDirect = [SubObjCDirectClass alloc];
    int correctAnswer = [subDirect aPlusBWithInt:one b:incorrectAnswer];
    // CHECK-EXE-STDOUT-NEXT: 42
    printf("%d\n", correctAnswer);

    int staticAdd = [SubObjCDirectClass staticAddWithA:one b:incorrectAnswer];
    // CHECK-EXE-STDOUT-NEXT: 42
    printf("%d\n", staticAdd);
    return 0;
}
