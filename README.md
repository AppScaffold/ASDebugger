# ASDebugger

[![CI Status](http://img.shields.io/travis/利伽/ASDebugger.svg?style=flat)](https://travis-ci.org/squarezw/ASDebugger)
[![Version](https://img.shields.io/cocoapods/v/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![License](https://img.shields.io/cocoapods/l/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)
[![Platform](https://img.shields.io/cocoapods/p/ASDebugger.svg?style=flat)](http://cocoapods.org/pods/ASDebugger)

ASDebugger is a remote debugging toolset for iOS App. 

it's a way remotely check any network transaction, effortlessly Mock Data, It is able to intergrate with CocoaPods easily, also it's alternative for proxy tools like Charles.

## Features

- [x] Remote debugging network request, response from iOS client without tools
- [x] Mock Data by manually set up on iOS client
- [x] Easily create mock response struct via live network response 
- [x] Automatically refresh observer network page on the Web client once acquire some response from iOS Client
- [x ] Automatically set mock environment on iOS client once set mock struct on the platform
- [ ] Transport Data could be compress

## Usage

Register an appkey on [AppScaffold](http://www.appscaffold.net) WebSite

And then place init codes into the AppDelegate function  `didFinishConfiguringLaunch.`

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
