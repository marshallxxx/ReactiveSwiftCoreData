//
//  NSManagedObjectContext+PerformanceTests.swift
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

class NSManagedObjectContext_PerformanceTests: XCTestCase {

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

    func testPerformanceOfObserveObject() {
        let performaceExpectation = expectation(description: "Expect high performance")
        
        generate(numberOfGroups: 100, numberOfContactsPerGroup: 100, numberOfPhoneNumbersPerContact: 100)
        let observingGroup = generate(numberOfGroups: 1, numberOfContactsPerGroup: 100, numberOfPhoneNumbersPerContact: 100).first!
        
        try! testMOC.save()
        
        let startDate = Date()
        
        testMOC.reactive.observe(object: observingGroup).observeResult { result in
            let updateTime = Date().timeIntervalSince(startDate)
            XCTAssertLessThan(updateTime, 0.1)
            performaceExpectation.fulfill()
        }
        
        observingGroup.name = NSUUID().uuidString
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Utils
    
    @discardableResult
    private func generate(numberOfGroups: Int, numberOfContactsPerGroup: Int, numberOfPhoneNumbersPerContact: Int) -> [Group] {
        var groups = [Group]()
        for _ in 0...numberOfGroups {
            let group = Group.new(in: testMOC)
            group.name = NSUUID().uuidString
            group.contacts = NSSet(array: generate(numberOfContacts: numberOfContactsPerGroup, numberOfPhoneNumbersPerContact: numberOfPhoneNumbersPerContact))
            groups.append(group)
        }
        return groups
    }
    
    @discardableResult
    private func generate(numberOfContacts: Int, numberOfPhoneNumbersPerContact: Int) -> [Contact] {
        var contacts = [Contact]()
        for _ in 0...numberOfContacts {
            let contact = Contact.new(in: testMOC)
            contact.name = NSUUID().uuidString
            contact.phoneNumbers = NSSet(array: generate(numberOfPhoneNumbers: numberOfPhoneNumbersPerContact))
            contacts.append(contact)
        }
        return contacts
    }
    
    @discardableResult
    private func generate(numberOfPhoneNumbers: Int) -> [PhoneNumber] {
        var phoneNumbers = [PhoneNumber]()
        for _ in 0...numberOfPhoneNumbers {
            let phoneNumber = PhoneNumber.new(in: testMOC)
            phoneNumber.title = NSUUID().uuidString
            phoneNumbers.append(phoneNumber)
        }
        return phoneNumbers
    }
    
}
