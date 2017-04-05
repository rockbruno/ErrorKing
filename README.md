# ErrorKing

[![CI Status](http://img.shields.io/travis/bruno-rocha-movile/ErrorKing.svg?style=flat)](https://travis-ci.org/bruno-rocha-movile/ErrorKing)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![License](https://img.shields.io/cocoapods/l/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![Platform](https://img.shields.io/cocoapods/p/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)

Smart error alerts and full-fledged empty state views on your ViewControllers just a protocol inheritance away.

To add ErrorKing to your ViewController, extend it with the ErrorProne protocol:

```swift
extension MyViewController: ErrorProne {}
```

That's it! You can now call your ViewController's new property: `errorKing`, and see it's effects.

```swift
self.errorKing.setError(title: "Damn!", description: "Sorry for that.", emptyStateText: "Something happened :(")
```

Now, the next time your ViewController is visible (if the user triggered a load but pushed another screen, for example), ErrorKing will display:

[![Error](http://i.imgur.com/VloOTJY.png)](http://cocoapods.org/pods/ErrorKing)
[![EmptyState](http://i.imgur.com/vQV99sP.png)](http://cocoapods.org/pods/ErrorKing)

# Additional Customization

To dictate what happens when the empty state's reload button is touched, override `ErrorProne`'s `errorKingEmptyStateReloadButtonTouched`:

```swift
extension MyViewController: ErrorProne {
    func errorKingEmptyStateReloadButtonTouched() {
        //load my stuff again
        errorKing.errorKingEmptyStateReloadButtonTouched() //This will remove the empty state from the screen.
    }
}
```

You can also program what happens before the empty state is displayed:

```swift
func actionBeforeDisplayingErrorKingEmptyState() {
    //do something before displaying the empty state screen, like disabling your tableView's scrolling
    errorKing.actionBeforeDisplayingErrorKingEmptyState() //Sets up and displays the empty state screen.
}
```

...and change the empty state's frame if needed:

```swift
self.errorKing?.setEmptyStateFrame(rect: aFrame)
```

## Providing your own EmptyState screen

To add your own Empty State view, simply make a .swift/.xib that has ErrorKingEmptyStateView as it's class or superclass and link the corresponding outlets, if you used a .xib, or set `errorLabel` and init a button that triggers `tryAgain:`, if you use view code. After that, call:

```swift
self.errorKing.setEmptyStateView(toView: myCustomEmptyState)
```

You can see it in action on the Example project.

[![ExampleEmptyState](http://i.imgur.com/Ge4BctQ.png)](http://cocoapods.org/pods/ErrorKing)

# Installation

### Carthage

```ruby
github "rockbruno/ErrorKing" "master"
```

### CocoaPods

```ruby
pod "ErrorKing"
```

## Author

rockbruno, brunorochaesilva@gmail.com

## License

ErrorKing is available under the MIT license. See the LICENSE file for more info.
