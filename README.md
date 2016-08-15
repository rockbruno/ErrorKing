# ErrorKing

[![CI Status](http://img.shields.io/travis/bruno-rocha-movile/ErrorKing.svg?style=flat)](https://travis-ci.org/bruno-rocha-movile/ErrorKing)
[![Version](https://img.shields.io/cocoapods/v/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![License](https://img.shields.io/cocoapods/l/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)
[![Platform](https://img.shields.io/cocoapods/p/ErrorKing.svg?style=flat)](http://cocoapods.org/pods/ErrorKing)

Add the ability of displaying smart error alerts and empty state views on your ViewControllers just by inheriting the ErrorProne protocol. No setup needed.

ErrorProne adds the errorKing variable to your ViewController. By calling it's setError() method, ErrorKing will store the error data and display an AlertView the next time your ViewController is visible - and an EmptyState view that does whatever you want after the reload button is touched.

```ruby
someAsyncDataLoading { error in
self.errorKing?.setError(title: "Damn!", description: "Sorry for that.", emptyStateText: "Something happened :(")
}
```

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ErrorKing is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ErrorKing"
```

## Author

bruno-rocha-movile, bruno.rocha@movile.com

## License

ErrorKing is available under the MIT license. See the LICENSE file for more info.
