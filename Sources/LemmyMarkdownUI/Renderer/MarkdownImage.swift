//
//  InlineImage.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

@Observable
public class MarkdownImage {
    public let children: [InlineNode]
    public let tooltip: String?
    public let url: URL
    public let fontSize: CGFloat
    public var image: Image?
    public var parentLink: URL?
    
    public func renderFullWidth(in configuration: MarkdownConfiguration) -> Bool {
        // Only custom emojis should be displayed inline. Custom emojis have tooltips.
        // People are unlikely to use tooltips in any other circumstances, so images
        // with tooltips are displayed inline. I haven't found a better way to test for
        // a custom emoji.
        switch configuration.imagePresentationMode {
        case .block: true
        case .inline: false
        case .contextual: tooltip == nil
        }
    }
    
    init(
        children: [InlineNode],
        url: URL,
        tooltip: String?,
        fontSize: CGFloat,
        parentLink: String?
    ) {
        self.children = children
        self.url = url
        self.tooltip = tooltip
        self.fontSize = fontSize
        if let parentLink, let url = URL(string: parentLink) {
            self.parentLink = url
        } else {
            self.parentLink = nil
        }
    }
}
