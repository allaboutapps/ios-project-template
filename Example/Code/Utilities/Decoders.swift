//
//  Decoders.swift
//  SmartSpender
//
//  Created by Gunter Hager on 04/09/2017.
//  Copyright © 2017 Hagleitner. All rights reserved.
//

import Foundation

struct Decoders {
    
    static let standardJSON: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Decoders.decodePuckDate)
        return decoder
    }()
    
    static func decodePuckDate(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        
        if let value = Formatters.isoDateFormatter.date(from: raw) {
            return value
        }
        
        if let value = Formatters.apiRenderedFormatter.date(from: raw) {
            return value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Couldn't decode Date from \(raw).")
        }
    }
    
}
