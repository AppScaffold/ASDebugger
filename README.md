# ASDebugger

ASDebugger is a remote debugging toolset. It is a client library and gateway server combination

[![CI Status](http://img.shields.io/travis/利伽/ASDebugger.svg?style=flat)](https://travis-ci.org/squarezw/ASDebugger)
[![Version](https://img.shields.io/cocoapods/v/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![License](https://img.shields.io/cocoapods/l/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![Platform](https://img.shields.io/cocoapods/p/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)

ASDebugger is a remote debugging toolset. It is a client library and gateway server combination

## Usage

Please register a appkey on [AppScaffold](http://www.appscaffold.net) WebSite

To connect automatically to the Observer Host:

```
[ASNetworkRecorder startWithHost:[DefaultHost] appKey:[YourAppKey]];
```

Stop recording

```
[ASNetworkRecorder stop]
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

## Author

squarezw

## License

ASDebugger is available under the MIT license. See the LICENSE file for more info.
