# Clocky

Present any Apple Watch face.

- No jailbreak or `MobileGestalt` modification is required.
- Works on all watchOS versions (please open an issue if it doesn't work for you).
- Has some limitations because it runs the watch face within an app.

## Build an unsigned IPA

On macOS with Xcode installed, run:

```sh
scripts/create_ipa.sh --bundle-id com.example.Clocky
```

The script builds the iOS companion and embedded watch app and writes `build/ipa/Clocky.ipa`. Use `--output PATH` to choose another destination. The IPA is unsigned; both apps must be signed with suitable provisioning profiles before installation.

## Credits

Idea by [mightywhite](https://github.com/mightywhite): [HermesEnabler#93](https://github.com/pookjw/HermesEnabler/pull/93)
