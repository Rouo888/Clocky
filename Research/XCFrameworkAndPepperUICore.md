# watchOS XCFramework Structure & PepperUICore Research

## watchOS Architectures & XCFramework Layout

### Supported watchOS Architectures
In the watchOS 27 SDK (`WatchOS27.3.sdk/SDKSettings.json`):
- **Device (`watchos`)**: `arm64`, `arm64_32`, `arm64e`, `arm64e.x1`, `armv7k`
  - System `.tbd` files declare targets: `[ armv7k-watchos, arm64-watchos, arm64e-watchos, arm64e.x1-watchos, arm64_32-watchos ]`
- **Simulator (`watchsimulator`)**: `arm64`, `x86_64` (and legacy `i386` in `.tbd` targets)
  - System `.tbd` files declare targets: `[ i386-watchos-simulator, x86_64-watchos-simulator, arm64-watchos-simulator ]`

### Xcode XCFramework Directory Naming Convention
When `xcodebuild -create-xcframework` packages a watchOS framework containing `arm64`, `arm64_32`, `arm64e`, and `arm64e.x1` for device and `arm64`, `x86_64` for simulator, it creates one directory per `(SupportedPlatform, SupportedPlatformVariant)` pair with architectures sorted alphabetically and joined by `_`:
- Device slice directory & `LibraryIdentifier`: `watchos-arm64_arm64_32_arm64e_arm64e.x1`
- Simulator slice directory & `LibraryIdentifier`: `watchos-arm64_x86_64-simulator`

## Extensionless UIKit/PepperUICore Watch App Lifecycle

- Calling `spUtils_setRunningExtensionlessWKApp(YES)` from `_WatchKitPrivate` before `UIApplicationMain(argc, argv, NSStringFromClass([SPApplication class]), NSStringFromClass([AppDelegate class]))` runs a pure Objective-C/Objective-C++ watchOS application using `UIWindowScene` and `UIViewController` without SwiftUI or a WatchKit Extension.
- `Info.plist` includes `UIApplicationSceneManifest` and `WKSupportsAlwaysOnDisplay = YES`.

## Status Bar Hiding on watchOS

- `PepperUICore` hooks `UIViewController` status bar appearance queries and checks `-[UIViewController prefersStatusBarHidden]` (as well as `puic_statusBarAlpha` and `puic_applicationStatusBarItem`).
- Overriding `- (BOOL)prefersStatusBarHidden` to return `YES` on the root `UIViewController` (such as `FaceViewController`) hides the system status bar time overlay so the clock face can occupy the full screen unobscured.

## PepperUICore List Collection View

- `PUICListCollectionViewController` (subclass of `UICollectionViewController`) provides the native watchOS carousel/list collection view layout (`PUICListCollectionView` + `PUICListCollectionViewLayout`).
- `PUICListPlatterCell` (subclass of `PUICPlatterCell` -> `UICollectionViewCell`) provides the standard watchOS platter cell appearance.
- Cells are configured using `UICollectionViewCellRegistration` with `[UIListContentConfiguration _defaultInsetGroupedCellConfiguration]`.
