//
//  File.swift
//  
//
//  Created by Sjmarf on 01/06/2024.
//

import SwiftUI

public enum HeadingLevel: Int {
    case _1 = 1
    case _2 = 2
    case _3 = 3
    case _4 = 4
    case _5 = 5
    case _6 = 6
    
    internal var font: UIFont {
        switch self {
        case ._1:
            .preferredFont(forTextStyle: .title1)
        case ._2:
            .preferredFont(forTextStyle: .title2)
        case ._3:
            .preferredFont(forTextStyle: .title3)
        default:
            .preferredFont(forTextStyle: .headline)
        }
    }
}
