//
//  NSManagedObjectContext+ObserveResultTests.swift
//  ReactiveSwiftCoreData_Test
//
//  Created by Evghenii Nicolaev on 7/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import ReactiveSwiftCoreData
import ReactiveSwift
import CoreData

class NSManagedObjectContext_ObserveResultTests: XCTestCase {
    
    var testMOC: NSManagedObjectContext!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        testMOC = NSManagedObjectContext.test
    }
    
    override func tearDown() {
        testMOC = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testObserveResult_insert() {
        let updateResultExpectation = expectation(description: "Expect to get object in stream when field is changed")
        var expectedNumberOfResults = [0, 1]

        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K.@count > 0", #keyPath(Group.contacts))

        testMOC.reactive.observeResult(for: fetchRequest)
            .take(first: 2)
            .observeResult({ result in
                switch result {
                case .success(let fetchResult):
                    XCTAssertEqual(expectedNumberOfResults.removeFirst(), fetchResult.count)
                case .failure:
                    XCTFail("Stream should not fail!")
                }

                if expectedNumberOfResults.isEmpty {
                    updateResultExpectation.fulfill()
                }
            })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let contact = Contact.new(in: self.testMOC)
            contact.name = "John Doe"

            let group = Group.new(in: self.testMOC)
            group.name = "Test group 9"
            group.contacts = NSSet(objects: contact)
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testObserveResult_delete() {
        let updateResultExpectation = expectation(description: "Expect to get object in stream when field is changed")
        var expectedNumberOfResults = [1, 0]

        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K.@count > 0", #keyPath(Group.contacts))

        let contact2 = Contact.new(in: testMOC)
        contact2.name = "John Doe"

        let group2 = Group.new(in: testMOC)
        group2.name = "Test group"
        group2.contacts = NSSet(objects: contact2)

        try! testMOC.save()

        testMOC.reactive.observeResult(for: fetchRequest)
            .take(first: expectedNumberOfResults.count)
            .observeResult({ result in
                switch result {
                case .success(let fetchResult):
                    XCTAssertEqual(expectedNumberOfResults.removeFirst(), fetchResult.count)
                case .failure:
                    XCTFail("Stream should not fail!")
                }

                if expectedNumberOfResults.isEmpty {
                    updateResultExpectation.fulfill()
                }
            })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.testMOC.delete(group2)
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}
