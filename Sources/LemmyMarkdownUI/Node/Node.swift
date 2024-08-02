//
//  Node.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

internal protocol Node {
    var children: [any Node] { get }
    var searchChildrenForLinks: Bool { get }
    var links: [LinkData] { get }
    var images: [LinkData] { get }
}
