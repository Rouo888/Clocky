# PepperUICore & Extensionless watchOS Research

## Extensionless UIKit/PepperUICore Watch App Lifecycle

- Calling `spUtils_setRunningExtensionlessWKApp(YES)` from `_WatchKitPrivate` before `UIApplicationMain(argc, argv, NSStringFromClass([SPApplication class]), NSStringFromClass([AppDelegate class]))` runs a pure Objective-C/Objective-C++ watchOS application using `UIWindowScene` and `UIViewController` without SwiftUI or a WatchKit Extension.
- `Info.plist` includes `UIApplicationSceneManifest` and `WKSupportsAlwaysOnDisplay = YES`.

### WatchKit connection bootstrap for WatchConnectivity

The [MiscellaneousPepperUICore watch app](https://github.com/pookjw/MiscellaneousWWDC25/tree/main/MiscellaneousPepperUICore) demonstrates additional WatchKit lifecycle setup for an app that calls `UIApplicationMain` directly. Clocky adapts that example as follows:

- `AppDelegate` creates and retains an `SPExtensionConnection` at launch, sets itself as its delegate, marks the connection as being in a suspended launch, and calls `setUpNativeAppWithServerIdentifer:`. The example obtains the identifier from `LSBundleRecord`; Clocky uses `NSBundle.mainBundle.bundleIdentifier`, whose equivalence for every launch configuration has not been verified.
- On `didReceiveNonClockKitEvent`, the delegate calls `connectWithIdentifier:completion:`. It forwards `extendLaunchTest` to the connection, completes watch actions, and logs direct XPC setup errors. The delegate also exposes the suspended-launch state expected by the reference implementation.
- In `scene:willConnectToSession:options:`, a `dispatch_once` block supplies the connection to `SPCompanionLogger`, calls `didFinishLaunching:`, sets the in-process remote interface's client identifier, and invokes its launch completions.
- In `sceneDidBecomeActive:`, another `dispatch_once` block calls `didActivate` and schedules a launch completion. Foreground and background callbacks are not once-only: they forward the reference's `appWillEnterForeground` call and set `afterWillEnterForeground` to `YES` and `NO`, respectively. The background call follows the example verbatim and its intent remains unverified.
- Clocky accesses the delegate through `SPApplication.sharedSPApplication` and declares the private WatchKit interfaces in separate `_WatchKitPrivate` headers. The watchOS 10.5 simulator WatchKit binary exports `SPExtensionConnection` and `SPCompanionLogger`; private method signatures, nullability, delegate method optionality, and behavior are inferred from the example and are not independently verified.

The reference also creates an `os_transaction` in `sceneDidBecomeActive:` and includes an unfinished background-task handler. Clocky does not reproduce either. These lifecycle hooks do not themselves activate a `WCSession`, provide a session delegate, or implement background transfer completion. Simulator and device-target builds succeeded, but actual session activation, connection setup, transfer delivery, and background behavior have not been verified with a paired device.

## Status Bar Hiding on watchOS

- `PepperUICore` hooks `UIViewController` status bar appearance queries and checks `-[UIViewController prefersStatusBarHidden]` (as well as `puic_statusBarAlpha` and `puic_applicationStatusBarItem`).
- Overriding `- (BOOL)prefersStatusBarHidden` to return `YES` on the root `UIViewController` (such as `FaceViewController`) hides the system status bar time overlay so the clock face can occupy the full screen unobscured.

## PepperUICore List Collection View

- `PUICListCollectionViewController` (subclass of `UICollectionViewController`) provides the native watchOS carousel/list collection view layout (`PUICListCollectionView` + `PUICListCollectionViewLayout`).
- `PUICListPlatterCell` (subclass of `PUICPlatterCell` -> `UICollectionViewCell`) provides the standard watchOS platter cell appearance.
- Cells are configured using `UICollectionViewCellRegistration` with `[UIListContentConfiguration _defaultInsetGroupedCellConfiguration]`.

## Face Category Pages

- Clocky's category list is presented inside `PUICNavigationController`; selecting a category pushes a `PUICPageViewController` subclass.
- Category names and face-bundle identifier mappings are stored in `Clocky/FaceCategories.plist`; unmatched bundles fall into Others. Both screens provide a UIKit cancel bar button to dismiss the presented navigation controller.
- The page controller supplies lightweight containers per face. Each container creates its `NTKFaceViewController` when appearing and removes it after disappearing to limit memory use; if the default face cannot be created the page remains empty. A tap recognizer forwards the page's face bundle to the existing face-selection delegate.
- `PUICPageViewController` uses its own `delegate` for page-change callbacks. Clocky's face-selection delegate is named `faceSelectionDelegate` to avoid overwriting it; assigning the category list to `delegate` caused an unrecognized `pageViewController:didChangeToIndex:` selector at runtime.
- `PUICPageViewController` initialization and `viewControllers` usage follow the `MiscellaneousPepperUICore` example. The lightweight containers are allocated up front, while actual face controllers follow the page appearance lifecycle; watchOS may temporarily show multiple pages during a transition. The effect on peak memory and tap behavior still requires device testing.
