# ASDebugger

[![CI Status](http://img.shields.io/travis/利伽/ASDebugger.svg?style=flat)](https://travis-ci.org/squarezw/ASDebugger)
[![Version](https://img.shields.io/cocoapods/v/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![License](https://img.shields.io/cocoapods/l/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![Platform](https://img.shields.io/cocoapods/p/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)

ASDebugger is a remote debugging toolset for iOS App. It is a client library and gateway server combination

it can remote debugging network requests, effortlessly Mock Data, Intergrated with iOS easily, without any tooling involved like Charles

## Usage

Please register an appkey on [AppScaffold](http://www.appscaffold.net) WebSite

And then we mostly put launch code in the AppDelegate class function of `didFinishConfiguringLaunch.`

```
ASDebugger.start(withAppKey: "[Your AppKey]", secret:"[Your Secret]")
```

Stop recording

```
ASDebugger.shared().stop
```


## Installation

ASDebugger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ASDebugger"
```

If you would like to use the latest version of ASDebugger, point to the Github repository directly.

```
pod 'ASDebugger', :git => 'https://github.com/AppScaffold/ASDebugger.git'
```


## Mock

```
ASDebugger.start(withAppKey: "[YourAppKey]", secret:"[Your Secret]").enableMock(withPath: "[API]")
```

## Author

squarezw

## License

ASDebugger is available under the MIT license. See the LICENSE file for more info.
