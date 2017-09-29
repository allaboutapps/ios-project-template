# ReactiveCodable
![Swift 3.0](https://img.shields.io/badge/Swift-4.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

ReactiveSwift JSON parsing helpers for Swift 4 JSON decoding.
Inspired by: [ReactiveMapper](https://github.com/aschuch/ReactiveMapper)

## Usage

### ReactiveSwift

ReactiveCodable supports JSON mapping for ReactiveSwift on values in a `Signal` or `SignalProducer` stream.

```swift
// Create model from a JSON dictionary
let jsonSignalProducer: SignalProducer<Data, NSError> = // ...
jsonSignalProducer.mapToType(User.self).startWithResult { result in
    // use the decoded User model
    let user: User? = result.value
}

// Create array of models from array of JSON dictionaries
let jsonSignalProducer: SignalProducer<Any, NSError> = // ...
jsonSignalProducer.mapToType([Task].self).startWithResult { result in
    // use the decoded array of Task models
    let tasks: [Task]? = result.value
}
```



## Version Compatibility

Current Swift compatibility breakdown:

| Swift Version                    | Framework Version |
| -------------------------------- | ----------------- |
| 4.x (tested with Xcode 9 beta 4) | 1.x               |

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "gunterhager/ReactiveCodable”
```

Then run `carthage update`.

#### 
