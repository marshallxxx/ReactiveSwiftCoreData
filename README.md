# ReactiveSwiftCoreData

[![CI Status](https://img.shields.io/travis/marshallxxx/ReactiveSwiftCoreData.svg?style=flat)](https://travis-ci.org/marshallxxx/ReactiveSwiftCoreData)
[![Version](https://img.shields.io/cocoapods/v/ReactiveSwiftCoreData.svg?style=flat)](https://cocoapods.org/pods/ReactiveSwiftCoreData)
[![License](https://img.shields.io/cocoapods/l/ReactiveSwiftCoreData.svg?style=flat)](https://cocoapods.org/pods/ReactiveSwiftCoreData)
[![Platform](https://img.shields.io/cocoapods/p/ReactiveSwiftCoreData.svg?style=flat)](https://cocoapods.org/pods/ReactiveSwiftCoreData)

This library is a thin wrapper arround **CoreData** to stream changes from `NSManagedObjectContext`.

## Requirements
* Swift 4.1

## How to use

`ReactiveSwiftCoreData` adds `.reactive` extension on `NSManagedObjectContext`. This extensions observe changes in managed object context. There is no need for managed object context to be saved in order to propagate events in the signal.

**`managedObjectContext.reactive.observeContext().observeValues { changeEvent in ... }`**

Observes changes in the provided managed object context.

```
public struct CoreDataChangeEvent {
    public let inserted: Set<NSManagedObject>
    public let updated: Set<NSManagedObject>
    public let deleted: Set<NSManagedObject>
    public let refreshed: Set<NSManagedObject>
}
```

**`managedObjectContext.reactive.observe(object: managedObject).observeResult { result in ... }`**

Observe updates of provided object in current context. Reacts to all relationships changes as well. In case object is deleted stream will error `CoreDataObserverError.objectDeleted`.

**`managedObjectContext.reactive.observeResult(for: fetchRequest).observeResult { result in .. }`**

Every time objects are deleted or inserted in managed object context it will fetch again provided request.

## Installation

ReactiveSwiftCoreData is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

####Not pushed to specs repo yet!

```ruby
pod 'ReactiveSwiftCoreData'
```

## License

ReactiveSwiftCoreData is available under the MIT license. See the LICENSE file for more info.

