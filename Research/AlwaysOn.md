# Always On Display Research

## Attempted 1 Hz updates

- `MiscellaneousPepperUICore`'s Always On example implements the private
  `_effectiveControllersForAlwaysOnTimelines` and `_timelinesForDateInterval:`
  hooks. It returns itself as the effective controller and constructs a
  `BLSAlwaysOnPeriodicTimeline` with a one-second interval and an empty
  configuration block.
- Returning Clocky's current `NTKFaceViewController` from
  `_effectiveControllersForAlwaysOnTimelines` did not produce 1 Hz updates
  in the user's device test.
- Clocky already had `WKSupportsAlwaysOnDisplay` enabled. Adding
  `PUICApplicationSupportsAlwaysOn` did not resolve the issue. The reference
  example has both keys and comments that either one should be sufficient.
- `BLSAlwaysOnPeriodicTimeline` belongs to the private BacklightServices
  framework. Directly linking its Objective-C class symbol resulted in a
  `Symbol not found: _OBJC_CLASS_$_BLSAlwaysOnPeriodicTimeline` error on the
  user's device. Runtime lookup with `objc_lookUpClass` avoided the direct
  symbol reference, but supplying a one-second periodic timeline still did
  not resolve the reported issue.

These experimental changes were removed. The cause of the missing 1 Hz
updates and whether additional face-rendering or Always On configuration is
needed remain unverified.
