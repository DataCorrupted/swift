// RUN: %target-swift-frontend -emit-ir -o - %s | %FileCheck %s

import Foundation

@objc
class ObjCDirectClass: NSObject {
  // Swift version of the function
  // CHECK: define hidden swiftcc i64 @"$s15attr_objcDirect15ObjCDirectClassC18some_direct_methodSiyF"(ptr swiftself %0) #{{[0-9]+}} {

  // Wrapper for ObjC
  // CHECK: define hidden i64 @"-[ObjCDirectClass some_direct_method]"(ptr %[[SELF:.*]]) #[[DIRECT:[0-9]+]] {
  // CHECK: %{{.*}} = call ptr @llvm.objc.retain(ptr %[[SELF]])
  // CHECK-NEXT: %{{.*}} = call swiftcc i64 @"$s15attr_objcDirect15ObjCDirectClassC18some_direct_methodSiyF"(ptr swiftself %[[SELF]]) #{{[0-9]+}}
  // CHECK-NEXT: call void @llvm.objc.release(ptr %[[SELF]])
  @objc @objcDirect
  final func some_direct_method() -> Int { return 0 }

  // CHECK: define hidden swiftcc i64 @"$s15attr_objcDirect15ObjCDirectClassC12staticAnswerSiyFZ"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define hidden i64 @"+[ObjCDirectClass staticAnswer]"(ptr %0) #[[DIRECT]] {
  // CHECK: %{{.*}} = call swiftcc i64 @"$s15attr_objcDirect15ObjCDirectClassC12staticAnswerSiyFZ"(ptr swiftself %{{.*}}) #{{[0-9]+}}
  @objc @objcDirect
  static func staticAnswer() -> Int { return 42; }

  // CHECK: define hidden void @"-[ObjCDirectClass directWithArgsWithInt:f:]"(ptr %0, i64 %1, float %2) #[[DIRECT]] {
  @objc @objcDirect
  final func directWithArgs(int: Int, f: Float) { return; }
}

extension ObjCDirectClass {
  // CHECK: define hidden swiftcc void @"$s15attr_objcDirect15ObjCDirectClassC08extendedC0yyF"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define hidden void @"-[ObjCDirectClass extendedDirect]"(ptr %[[SELF:.*]]) #[[DIRECT]] {
  // CHECK: %{{.*}} = call ptr @llvm.objc.retain(ptr %[[SELF]])
  // CHECK-NEXT: call swiftcc void @"$s15attr_objcDirect15ObjCDirectClassC08extendedC0yyF"(ptr swiftself %[[SELF]]) #{{[0-9]+}}
  // CHECK-NEXT: call void @llvm.objc.release(ptr %[[SELF]])
  @objc @objcDirect
  final func extendedDirect() { return }
}

@objc
public class PublicClass : NSObject {
  // CHECK: define internal swiftcc void @"$s15attr_objcDirect11PublicClassC13privateMethod33_83A4DAAD1CD00CC69D1657D042158159LLyyF"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define internal void @"-[PublicClass privateMethod]"(ptr %0) #[[DIRECT]] {
  // CHECK: call swiftcc void @"$s15attr_objcDirect11PublicClassC13privateMethod33_83A4DAAD1CD00CC69D1657D042158159LLyyF"(ptr swiftself %0) #{{[0-9]+}}
  @objc @objcDirect
  private final func privateMethod() { return }

  // CHECK: define swiftcc void @"$s15attr_objcDirect11PublicClassC12publicMethodyyF"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define void @"-[PublicClass publicMethod]"(ptr %0) #{{[0-9]+}} {
  // CHECK: call swiftcc void @"$s15attr_objcDirect11PublicClassC12publicMethodyyF"(ptr swiftself %0) #{{[0-9]+}}
  @objc @objcDirect
  public final func publicMethod() { return }

  // CHECK: define internal swiftcc void @"$s15attr_objcDirect11PublicClassC17filePrivateMethod33_83A4DAAD1CD00CC69D1657D042158159LLyyF"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define internal void @"-[PublicClass filePrivateMethod]"(ptr %0) #{{[0-9]+}} {
  // CHECK: call swiftcc void @"$s15attr_objcDirect11PublicClassC17filePrivateMethod33_83A4DAAD1CD00CC69D1657D042158159LLyyF"(ptr swiftself %0) #{{[0-9]+}}
  @objc @objcDirect
  fileprivate final func filePrivateMethod() { return }
}

@objc
internal class InternalClass : NSObject {
  // CHECK: define hidden swiftcc void @"$s15attr_objcDirect13InternalClassC12publicMethodyyF"(ptr swiftself %0) #{{[0-9]+}} {
  // CHECK: define hidden void @"-[InternalClass publicMethod]"(ptr %0) #{{[0-9]+}} {
  // CHECK: call swiftcc void @"$s15attr_objcDirect13InternalClassC12publicMethodyyF"(ptr swiftself %0) #{{[0-9]+}}
  @objc @objcDirect
  public final func publicMethod() { return }
}

// CHECK: attributes #[[DIRECT]] = { {{.*}} "objc_direct" {{.*}} }
