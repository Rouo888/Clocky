# watchOS XCFramework Research

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

## InterfaceGenerator Workflow

- `InterfaceGenerator` is a macOS command-line tool target in `Clocky.xcodeproj` (`InterfaceGenerator -p <project_root>`) that keeps the custom `.xcframework` definitions (`_UIKitPrivate`, `_WatchKitPrivate`, `_ClockKitPrivate`, `PepperUICore`, `NanoTimeKit`) synchronized across slices.
- Using `watchos-arm64_x86_64-simulator` as the base slice:
  1. It copies `Headers/` from the base simulator slice to `watchos-arm64_arm64_32_arm64e_arm64e.x1`.
  2. It rewrites the `.tbd` target list from the simulator targets (`i386-watchos-simulator, x86_64-watchos-simulator, arm64-watchos-simulator`) to the device targets (`armv7k-watchos, arm64-watchos, arm64e-watchos, arm64e.x1-watchos, arm64_32-watchos`).
