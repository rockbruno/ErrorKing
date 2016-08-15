# ErrorKing

[![CI Status](http://img.shields.io/travis/bruno-rocha-movile/ErrorKing.svg?style=flat)](https://travis-ci.org/bruno-rocha-movile/ErrorKing)
[![Version](https://img.shields.io/cocoapods/v/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![License](https://img.shields.io/cocoapods/l/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![Platform](https://img.shields.io/cocoapods/p/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)

Add the ability of displaying smart error alerts and empty state views on your ViewControllers just by inheriting the ErrorProne protocol. No setup needed.

ErrorProne adds the errorKing variable to your ViewController. By calling it's setError() method, ErrorKing will store the error data and display an AlertView the next time your ViewController is visible - and an EmptyState view that does whatever you want after the reload button is touched.

```swift
self.errorKing?.setError(title: "Damn!", description: "Sorry for that.", emptyStateText: "Something happened :(")
```

The next time the ViewController is visible (if the user triggered a load but pushed another screen, for example), the user will be greeted with:

[![Error](http://i.imgur.com/VloOTJY.png)](http://cocoapods.org/pods/ErrorKing)
[![EmptyState](http://i.imgur.com/vQV99sP.png)](http://cocoapods.org/pods/ErrorKing)

# Instructions
To add ErrorKing to your ViewController, add the ErrorProne protocol:

```swift
extension MyViewController: ErrorProne {
}
```

That's it! You can now call the setError() method and see it's effects.

To program what happens when the Empty State's reload button is touched, add this protocol method to your extension:

```swift
extension MyViewController: ErrorProne {
func errorKingEmptyStateReloadButtonTouched() {
//load my stuff again
errorKing?.errorKingEmptyStateReloadButtonTouched()
}
}
```

Additionally, you can further customize ErrorKing by telling what happens before the empty state screen is displayed:

```swift
func actionBeforeDisplayingErrorKingEmptyState() {
//do something before displaying the empty state screen, like disabling your tableView's scrolling
errorKing?.actionBeforeDisplayingErrorKingEmptyState()
}
```

Also, by changing the Empty state view's frame:

```swift
self.errorKing?.setEmptyStateFrame(rect: aFrame)
```

And by providing your own EmptyState view:

```swift
self.errorKing?.setEmptyStateView(toView: myCustomEmptyState)
```

## Installation

ErrorKing is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ErrorKing"
```

## Author

kingrocha, brunorochaesilva@movile.com

## License

ErrorKing is available under the MIT license. See the LICENSE file for more info.
