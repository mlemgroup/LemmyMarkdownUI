//
//  InlineMarkdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct MarkdownText: View {
    
    private var type: InlineRenderer.InlineType
    private var configuration: MarkdownConfiguration
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration
    ) {
        self.init(
            [BlockNode].init(markdown),
            configuration: configuration
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        configuration: MarkdownConfiguration
    ) {
        self.type = InlineRenderer(inlines: inlines, configuration: configuration).type
        self.configuration = configuration
    }
    
    public init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfiguration
    ) {
        self.type = InlineRenderer(blocks: blocks, configuration: configuration).type
        self.configuration = configuration
    }
    
    public var body: some View {
        switch type {
        case let .text(components, images):
            components.text(configuration: configuration)
                .task {
                    for image in images {
                        await configuration.inlineImageLoader(image)
                    }
                }
        case let .singleImage(image):
            configuration.imageBlockView(image)
        }
    }
}

@available(*, deprecated, renamed: "MarkdownText")
public typealias InlineMarkdown = MarkdownText
