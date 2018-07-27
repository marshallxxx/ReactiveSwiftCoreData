//
//  NSManagedObjectContext+ObserveObjectTests.swift
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

class NSManagedObjectContext_ObserveObjectTests: XCTestCase {
    
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
    
    func testObjectFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")
        
        let group = Group.new(in: testMOC)
        group.name = "Test group"
        try! testMOC.save()
        
        testMOC.reactive.observe(object: group).take(first: 1).observeResult { result in
            switch result {
            case .success(let group):
                XCTAssertEqual(group.name, "Updated test group")
            case .failure:
                XCTFail("Should not get any error in stream")
            }
            
            objectUpdateExpectation.fulfill()
        }
        
        group.name = "Updated test group"
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testObjectOneLevelRelationshipFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")
        
        let contact = Contact.new(in: testMOC)
        contact.name = "John Doe"
        
        let group = Group.new(in: testMOC)
        group.name = "Test group"
        group.contacts = NSSet(objects: contact)
        
        try! testMOC.save()
        
        testMOC.reactive.observe(object: group).take(first: 1).observeResult { result in
            switch result {
            case .success(let group):
                let updatedContactName = (group.contacts?.allObjects.first as? Contact)?.name
                XCTAssertEqual(updatedContactName, "Alice")
            case .failure:
                XCTFail("Should not get any error in stream")
            }
            
            objectUpdateExpectation.fulfill()
        }
        
        contact.name = "Alice"
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testObjectTwoLevelRelationshipFieldUpdate() {
        let objectUpdateExpectation = expectation(description: "Expect to get object in stream when field is changed")
        
        let phoneNumber = PhoneNumber.new(in: testMOC)
        phoneNumber.phoneNumber = "987654321"
        phoneNumber.title = "Mobile"
        
        let contact = Contact.new(in: testMOC)
        contact.name = "John Doe"
        contact.phoneNumbers = NSSet(objects: phoneNumber)
        
        let group = Group.new(in: testMOC)
        group.name = "Test group"
        group.contacts = NSSet(objects: contact)
        
        try! testMOC.save()
        
        testMOC.reactive.observe(object: group).take(first: 1).observeResult { result in
            switch result {
            case .success(let group):
                let updatedPhoneNumber = ((group.contacts?.allObjects.first as? Contact)?.phoneNumbers?.allObjects.first as? PhoneNumber)?.phoneNumber
                XCTAssertEqual(updatedPhoneNumber, "987654321")
            case .failure:
                XCTFail("Should not get any error in stream")
            }
            
            objectUpdateExpectation.fulfill()
        }
        
        phoneNumber.phoneNumber = "987654321"
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testObjectDeletion() {
        let objectDeleteExpectation = expectation(description: "Expect to get an error in stream when object deleted")
        
        let group = Group.new(in: testMOC)
        group.name = "Test group"
        
        try! testMOC.save()
        
        testMOC.reactive.observe(object: group).observeResult { result in
            switch result {
            case .success:
                XCTFail("Should not get any value in stream")
            case .failure(let error):
                XCTAssertEqual(error, CoreDataObserverError.objectDeleted)
            }
            
            objectDeleteExpectation.fulfill()
        }
        
        testMOC.delete(group)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}
