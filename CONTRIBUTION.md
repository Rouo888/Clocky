# Contribution Guidelines

This document defines the coding conventions, header authoring rules, and architectural guidelines for **Clocky**.

## 1. Language, Deployment Target & Memory Management

- **No SwiftUI**: The project is written strictly in Objective-C (`.m`) and Objective-C++ (`.mm`) using UIKit (`_UIKitPrivate`), `PepperUICore`, `_WatchKitPrivate`, and `NanoTimeKit`.
- **Minimum Deployment Target**: `watchOS 9.0` (`WATCHOS_DEPLOYMENT_TARGET = 9.0`, the minimum watchOS version supported by Xcode 27.3).
- **Manual Retain-Release (MRR / Non-ARC)**:
  - ARC is disabled (`CLANG_ENABLE_OBJC_ARC = NO`).
  - Manage object lifetimes explicitly using `retain`, `release`, `autorelease`, and `[super dealloc]` in `-dealloc`.

## 2. Constants & Extern Declarations (`Defines.h`)

- Define shared constants and keys (such as `NSUserDefaults` keys) in `Defines.h` / `Defines.m` using the `CKT_EXTERN` macro and function accessors rather than file-local `static` variables:
  ```objc
  #ifdef __cplusplus
  #define CKT_EXTERN  extern "C" __attribute__((visibility ("default")))
  #else
  #define CKT_EXTERN  extern __attribute__((visibility ("default")))
  #endif

  CKT_EXTERN NSString * selectedFaceIdentifierKey(void);
  ```

## 3. Calling Private APIs

- **No Objective-C Runtime Dynamic Dispatch for API Calls**:
  - Avoid calling private APIs via `objc_msgSend`, `NSClassFromString`, `objc_lookUpClass`, `objc_getClass`, `NSSelectorFromString`, or `sel_registerName`.
  - Instead, declare the classes, methods, and properties in the appropriate `.xcframework` header (`.h`) and export their symbols/classes in the corresponding `.tbd` stub file so they are checked at compile time and linked directly.
- **Availability Annotations over `-respondsToSelector:`**:
  - When calling private APIs, do **not** guard calls with `-respondsToSelector:`. Instead, annotate declarations with `API_AVAILABLE(...)` (and `@available` if version checks are needed above the `watchOS 9.0` deployment target).
  - (`-respondsToSelector:` should only be used for checking optional delegate protocol methods defined by our own delegates.)
- **Minimal Declarations**:
  - Only declare the classes, protocols, properties, methods, and enums in private `.h` files that are actually used by the project. Do not dump unused methods or remove needed ones.
  - Omit unnecessary comments in recreated SDK/private headers.

## 4. Private Header (`.h`) Authoring Rules

- **Strict Typing & Nullability**:
  - Wrap headers in `NS_HEADER_AUDIT_BEGIN(nullability, sendability)` / `NS_HEADER_AUDIT_END(nullability, sendability)` (or `NS_ASSUME_NONNULL_BEGIN` / `NS_ASSUME_NONNULL_END`).
  - Never use untyped `id` out of convenience. Always specify the exact class or protocol type.
  - Annotate nullable parameters, return types, and properties explicitly with `_Nullable` / `nullable`.
  - Use `__kindof` where polymorphic subclasses are returned or passed (e.g., `__kindof NTKFaceBundle *`, `__kindof NTKFace *`, `__kindof UICollectionViewCell *`).
- **`NS_NOESCAPE` on Synchronous Blocks**:
  - Annotate non-escaping block parameters (such as enumeration blocks or synchronous configuration blocks) with `NS_NOESCAPE`, e.g.:
    ```objc
    - (void)enumerateFaceBundlesOnDevice:(CLKDevice *)device includingLegacy:(BOOL)includingLegacy withBlock:(void (NS_NOESCAPE ^)(__kindof NTKFaceBundle *faceBundle))block;
    ```
- **Preserve Xcode / iOS UIKit Header Structure in `_UIKitPrivate`**:
  - When adding UIKit declarations to `_UIKitPrivate`, mirror the exact file names, category names, declaration positions, and import order from the iOS `UIKit.framework` headers (without comments).
  - For example:
    - `UIViewGeometry`, `UIViewHierarchy`, `UIViewGestureRecognizers` categories in `UIView.h`
    - `UIContainerViewControllerProtectedMethods`, `UIContainerViewControllerCallbacks` categories in `UIViewController.h`
    - `UICollectionViewCellRegistration` in `UICollectionViewItemRegistration.h`
    - `NSIndexPath (UIKitAdditions)` in `NSIndexPath+UIKitAdditions.h`

## 5. Delegate Pattern Conventions

- Communicate between child/presented view controllers and their parent/presenting view controllers using a delegate protocol.
- Mark delegate callbacks as `@optional` and follow the naming pattern:
  ```objc
  @protocol NameViewControllerDelegate <NSObject>
  @optional
  - (void)nameViewController:(NameViewController *)viewController didSelectItem:(ItemType *)item;
  @end
  ```

## 6. Method Swizzling Conventions

- All method swizzling lives in `Swizzler.h` / `Swizzler.mm` and is invoked from `+[AppDelegate load]` in `AppDelegate.mm`.
- Use `#include <objc/runtime.h>` and `#include <objc/message.h>` (use `#include` instead of `#import` for `<objc/...>` headers).
- Use `reinterpret_cast` for all function pointer and `IMP` casts.
- Organize each swizzled method under nested C++ namespaces `swizzler::<ClassName>::<methodName>` containing `original`, `custom`, and `swizzle()`:
  ```objc
  namespace swizzler {
      namespace NTKFaceDescriptor {
          namespace isAvailableForDevice {
              BOOL (* _Nullable original)(::NTKFaceDescriptor *self, SEL _cmd, CLKDevice *device);
              BOOL custom(::NTKFaceDescriptor *self, SEL _cmd, CLKDevice *device) {
                  return YES;
              }
              void swizzle() {
                  Method method = class_getInstanceMethod([::NTKFaceDescriptor class], @selector(isAvailableForDevice:));
                  assert(method != NULL);
                  original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
                  method_setImplementation(method, reinterpret_cast<IMP>(custom));
              }
          }
      }
  }
  ```

## 7. Synchronizing XCFrameworks with `InterfaceGenerator`

- Whenever headers (`.h`) or `.tbd` exports are modified in a custom `.xcframework` (`_UIKitPrivate`, `_WatchKitPrivate`, `PepperUICore`, `NanoTimeKit`), make the primary edits in the `watchos-arm64_x86_64-simulator` slice and run `InterfaceGenerator -p <project_root>` to propagate headers and `.tbd` targets across all slices.
- Ensure `InterfaceGenerator/Subclasses` only defines generators for the `.xcframework` bundles actively used by the project.
