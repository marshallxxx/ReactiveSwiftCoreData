//
//  CoreDataObserver.swift
//  ReactiveSwiftCoreData
//
//  Created by Evghenii Nicolaev on 7/18/18.
//

import Foundation
import CoreData
import ReactiveSwift
import Result

public struct CoreDataChangeEvent {
    public let inserted: Set<NSManagedObject>
    public let updated: Set<NSManagedObject>
    public let deleted: Set<NSManagedObject>
    public let refreshed: Set<NSManagedObject>
}

class CoreDataObserver {

    private let managedObjectContext: NSManagedObjectContext
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var notificationObserver: NSObjectProtocol?
    private let (coreDataChangesSignal, coreDataChangesObserver) = Signal<CoreDataChangeEvent, NoError>.pipe()
    
    var changeSignal: Signal<CoreDataChangeEvent, NoError> {
        return coreDataChangesSignal
    }

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator

        notificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                                      object: nil,
                                                                      queue: nil) { [weak self] (notification) in
                                                                        self?.contextObjectsDidChange(notification)
        }
    }

    private func contextObjectsDidChange(_ notification: Notification) {
        guard let incomingContext = notification.object as? NSManagedObjectContext,
            let persistentStoreCoordinator = persistentStoreCoordinator,
            let incomingPersistentStoreCoordinator = incomingContext.persistentStoreCoordinator,
            persistentStoreCoordinator == incomingPersistentStoreCoordinator else {
                return
        }
        
        coreDataChangesObserver.send(value: CoreDataChangeEvent(inserted: notification.coreDataInsertions,
                                                                updated: notification.coreDataUpdates,
                                                                deleted: notification.coreDataDeletions,
                                                                refreshed: notification.coreDataRefreshes))
    }
    
}

private extension Notification {
 
    var coreDataInsertions: Set<NSManagedObject> {
        return (userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }
    
    var coreDataUpdates: Set<NSManagedObject> {
        return (userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }
    
    var coreDataDeletions: Set<NSManagedObject> {
        return (userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }
    
    var coreDataRefreshes: Set<NSManagedObject> {
        return (userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }
    
}
