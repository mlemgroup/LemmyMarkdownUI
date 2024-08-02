//
//  InlineImage.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

@Observable
public class InlineImage {
    public let children: [InlineNode]
    public let tooltip: String?
    public let url: URL
    public let fontSize: CGFloat
    public var image: Image?
    public let truncated: Bool
    public var renderFullWidth: Bool = false
    
    init(children: [InlineNode], url: URL, tooltip: String?, fontSize: CGFloat, truncated: Bool = false) {
        self.children = children
        self.url = url
        self.tooltip = tooltip
        self.fontSize = fontSize
        self.truncated = truncated
    }
}
