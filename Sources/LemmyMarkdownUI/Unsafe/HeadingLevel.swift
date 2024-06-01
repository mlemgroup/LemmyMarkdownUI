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
    
    internal var font: Font {
        switch self {
        case ._1:
            .title.weight(.bold)
        case ._2:
            .title2.weight(.bold)
        case ._3:
            .title3.weight(.semibold)
        default:
            .headline.weight(.semibold)
        }
    }
}
