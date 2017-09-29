//
//  ReactiveCodableTests.swift
//  ReactiveCodableTests
//
//  Created by Gunter Hager on 01/08/2017.
//  Copyright © 2017 Gunter Hager. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import ReactiveCodable

class ReactiveCodableTests: XCTestCase {
    
    let mockData = MockDataLoader()
    
    func testMapToObject() {
        var user: User?
        mockData.load("user")
            .mapToType(User.self)
            .startWithResult { user = $0.value }
        
        XCTAssertNotNil(user, "mapToType should not return nil user")
    }
    
    func testMapToObjectArray() {
        var tasks: [Task]?
        mockData.load("tasks")
            .mapToType([Task].self)
            .startWithResult { tasks = $0.value }
        
        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }
    
    func testInvalidTasks() {
        var invalidTasks: [Task]? = nil
        mockData.load("tasks_invalid")
            .mapToType([Task].self)
            .startWithResult { invalidTasks = $0.value }

        XCTAssert(invalidTasks == nil, "mapToType should return nil tasks for invalid JSON")
    }

    func testInvalidUser() {
        var invalidUser: User? = nil
        mockData.load("user_invalid")
            .mapToType(User.self)
            .startWithResult { invalidUser = $0.value }

        XCTAssert(invalidUser == nil, "mapToType should return nil user for invalid JSON")
    }

    func testUnderlyingError() {
        var error: ReactiveCodableError?
        let sentError = NSError(domain: "test", code: -9000, userInfo: nil)
        let (signal, sink) = Signal<Data, NSError>.pipe()
        
        signal.mapToType(User.self).observeFailed { error = $0 }
        sink.send(error: sentError)

        XCTAssertNotNil(error, "error should not be nil")
        XCTAssertEqual(error?.nsError, sentError, "the sent error should be wrapped in an .Underlying error")
    }
    
    func testOwnDecoder() {
        var tasks: [Task]?
        let decoder = JSONDecoder()
        mockData.load("tasks")
            .mapToType([Task].self, decoder: decoder)
            .startWithResult { tasks = $0.value }
        
        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }
    


}
