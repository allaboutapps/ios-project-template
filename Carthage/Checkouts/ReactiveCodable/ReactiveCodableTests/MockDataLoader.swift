//
//  MockDataLoader.swift
//  ReactiveCodableTests
//
//  Created by Gunter Hager on 01/08/2017.
//  Copyright © 2017 Gunter Hager. All rights reserved.
//

import Foundation
import ReactiveSwift

class MockDataLoader {
    
    func load(_ fileName: String) -> SignalProducer<Data, NSError> {
        let json = jsonData(fileName)
        return SignalProducer(value: json)
    }
    
    // MARK: Helper
    
    private func jsonData(_ name: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
}
