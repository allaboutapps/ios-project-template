//
//  LogController.swift
//  Example
//
//  Created by Andreas Tinoco Lobo on 06/05/16.
//  Copyright © 2016 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

struct LogController {
    
    static var fileDestination: FileDestination?
    
    static func setupLogger() {
        let consoleDestionation = ConsoleDestination()
        consoleDestionation.colored = false
        log.addDestination(consoleDestionation)
        
        if Environment.current() == .Debug {
            fileDestination = FileDestination()
        }
    }
}
