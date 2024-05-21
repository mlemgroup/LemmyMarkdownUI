//
//  LemmyLinkType.swift
//
//
//  Created by Sjmarf on 21/05/2024.
//

import Foundation

public enum LemmyLinkType {
    case community, person
    
    var urlIdentifier: String {
        switch self {
        case .community:
            "c"
        case .person:
            "u"
        }
    }
}
