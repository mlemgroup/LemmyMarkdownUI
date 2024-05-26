//
//  File.swift
//  
//
//  Created by Sjmarf on 26/05/2024.
//

import Foundation

internal extension [any Node] {
    var links: [LinkData] {
        self.reduce([], { $0 + $1.links })
    }
}
