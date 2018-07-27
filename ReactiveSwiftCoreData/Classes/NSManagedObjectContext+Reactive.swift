//
//  NSManagedObjectContext+Reactive.swift
//  ReactiveSwiftCoreData
//
//  Created by Evghenii Nicolaev on 7/18/18.
//

import Foundation
import CoreData
import ReactiveSwift
import Result

public enum CoreDataObserverError: Error {
    case unknown
    case objectDeleted
}

extension NSManagedObjectContext: ReactiveExtensionsProvider {}

public extension Reactive where Base == NSManagedObjectContext {

    /// Observes changes in current context
    ///
    /// - Returns: Signal that captures context change event
    public func observeContext() -> Signal<CoreDataChangeEvent, NoError> {
        
        return Signal({ (observer, lifetime) in
            var coreDataObserver: CoreDataObserver! = CoreDataObserver(managedObjectContext: base)
            let disposable = coreDataObserver.changeSignal.observe(observer)

            lifetime.observeEnded {
                coreDataObserver = nil
                disposable?.dispose()
            }
        })
    }

    /// Observe changes of provided object in current context. Reacts to all relationships changes as well.
    ///
    /// - Parameter object: NSManagedObject to be observed
    /// - Returns: Signal that return observed object every time some fields are modified
    public func observe<T: NSManagedObject>(object: T) -> Signal<T, CoreDataObserverError> {
        return Signal({ (observer, lifetime) in
            var coreDataObserver: CoreDataObserver! = CoreDataObserver(managedObjectContext: base)
            let disposable = coreDataObserver.changeSignal.observeValues({ changeEvent in
                
                // Check for deletion
                let deletedSet = Set(changeEvent.deleted.map({ $0.objectID }))
                guard !deletedSet.contains(object.objectID) else {
                    observer.send(error: CoreDataObserverError.objectDeleted)
                    return
                }
                
                // Check for changes
                let interestSet = object.relationshipIDs.union([ object.objectID ])
                let changedSet = Set(changeEvent.updated.map({ $0.objectID }))
                if !changedSet.intersection(interestSet).isEmpty {
                    observer.send(value: object)
                }
            })
            
            lifetime.observeEnded {
                coreDataObserver = nil
                disposable?.dispose()
            }
        })
    }

    /// Observe result of NSFetchRequest
    ///
    /// - Parameter request: Fetch request to be executed everytime context is updated
    /// - Returns: Signal that return new result everytime context new object is inserted or deleted.
    public func observeResult<T: NSManagedObject>(for request: NSFetchRequest<T>) -> Signal<[T], CoreDataObserverError> {
        func executeFetch(with observer: Signal<[T], CoreDataObserverError>.Observer) {
            do {
                let result = try base.fetch(request)
                observer.send(value: result)
            } catch {
                observer.send(error: CoreDataObserverError.unknown)
            }
        }

        return Signal({ (observer, lifetime) in
            // Issue: We delay sending value as it will not be catched by subscription 🤷🏼‍♂️
            DispatchQueue.main.async {
                executeFetch(with: observer)
            }

            var coreDataObserver: CoreDataObserver! = CoreDataObserver(managedObjectContext: base)
            let disposable = coreDataObserver.changeSignal
                .map({ changeEvent in
                    return !changeEvent.deleted.union(changeEvent.inserted).isEmpty
                })
                .filter { $0 }
                .observeValues({ _ in
                    executeFetch(with: observer)
                })

            lifetime.observeEnded {
                coreDataObserver = nil
                disposable?.dispose()
            }
        })
    }

}

private extension NSManagedObject {
    
    var relationshipIDs: Set<NSManagedObjectID> {
        var relationshipIDs = Set<NSManagedObjectID>()
        
        for relationship in entity.relationshipsByName {
            let relationshipObjectIds = objectIDs(forRelationshipNamed: relationship.key)
            relationshipIDs.formUnion(relationshipObjectIds)
            
            for id in relationshipObjectIds {
                if let object = managedObjectContext?.object(with: id) {
                    relationshipIDs.formUnion(object.relationshipIDs)
                }
            }
        }
        
        return relationshipIDs
    }
    
}
