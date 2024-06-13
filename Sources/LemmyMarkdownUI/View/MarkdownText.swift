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
    private var loadImages: Bool
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration,
        loadImages: Bool = false
    ) {
        self.init(
            [BlockNode].init(markdown),
            configuration: configuration,
            loadImages: loadImages
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        configuration: MarkdownConfiguration,
        loadImages: Bool = false
    ) {
        self.type = InlineRenderer(inlines: inlines, configuration: configuration).type
        self.configuration = configuration
        self.loadImages = loadImages
    }
    
    public init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfiguration,
        loadImages: Bool = false
    ) {
        self.type = InlineRenderer(blocks: blocks, configuration: configuration).type
        self.configuration = configuration
        self.loadImages = loadImages
    }
    
    public var body: some View {
        switch type {
        case let .text(components, images):
            components.text(configuration: configuration)
                .task {
                    if loadImages {
                        for image in images {
                            await configuration.inlineImageLoader(image)
                        }
                    }
                }
                .foregroundStyle(configuration.primaryColor)
        case let .singleImage(image):
            configuration.imageBlockView(image)
        }
    }
}

@available(*, deprecated, renamed: "MarkdownText")
public typealias InlineMarkdown = MarkdownText
