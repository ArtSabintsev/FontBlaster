# FontBlaster

### Programmatically load custom fonts into your iOS app.

---
### About

Say goodbye to importing custom fonts via property lists as **FontBlaster** automatically imports and loads all fonts in your app's NSBundles with one line of code. 

### Changelog (v1.0.1)
- Updated sample project

### Features
- [x] CocoaPods Support
- [x] Automatically imports fonts from `NSBundle.mainbundle()`
- [x] Automatically imports fonts from bundles inside your `mainBundle`
- [x] Able to imports fonts from remote bundles
- [x] Sample Project

### Installation Instructions

#### CocoaPods Installation
```ruby
pod 'FontBlaster'
```

- Add `import FontBlaster` to any `.Swift` file that references Siren via a CocoaPods installation.
- Requires [CocoaPods 0.36 prerelease](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) or later
- Only for apps with a minimum deployment target of iOS 8.0 or later

    > CocoaPods does not support pods written in Swift on iOS 7. For more information, please see [this issue](https://github.com/CocoaPods/swift/issues/22).
  
If your app needs to support iOS 7, use **Manual Installation**.

#### Manual Installation

1. [Download FontBlaster](//github.com/ArtSabintsev/FontBlaster/archive/master.zip).
2. Copy the `FontBlaster.swift` into your project.

### Setup Instructions	

Typically, all fonts are automatically found in `NSBundle.mainBundle()`. Even if you have a custom bundle, it's usually lodged inside of the `mainBundle.` Therefore, to load all the fonts in your application, irrespective of the bundle it's in, simply call:

```Swift
FontBlaster.blast()
```

If your fonts failed to load, or if you are loading from a bundle that isn't found inside your app's `mainBundle`, simply pass a reference to your `NSBundle` in the overloaded `blast(_:)` method:

```Swift
FontBlaster.blast(_:) // Takes one argument of type NSBundle
```

To turn on console debug statements, simply set `debugEnabled() = true` **before** calling either `blast()` method:

```Swift
FontBlaster.debugEnabled = true
FontBlaster.blast()
```

### Sample Project
A Sample iOS project is included in the repo. When you launch the app, all fonts are configured to load custom fonts, but don't actually display them *until* you push the button. After pushign the button, **FontBlaster** imports your fonts and updates all the fonts automatically.

### Special Thanks
This project builds upon an old solution that [Marco Arment](http://twitter.com/marcoarment) proposed and wrote about on his [blog](www.marco.org/2012/12/21/ios-dynamic-font-loading).

### Created and maintained by
[Arthur Ariel Sabintsev](http://www.sabintsev.com/)
