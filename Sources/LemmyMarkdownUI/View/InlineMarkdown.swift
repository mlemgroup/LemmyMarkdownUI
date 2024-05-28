//
//  InlineMarkdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct InlineMarkdown: View {
    
    var renderer: InlineRenderer
    var configuration: MarkdownConfiguration
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration
    ) {
        self.init(
            [InlineNode].init(markdown),
            configuration: configuration
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        configuration: MarkdownConfiguration
    ) {
        self.renderer = .init(inlines: inlines, configuration: configuration)
        self.configuration = configuration
    }
    
    private func text(components: [InlineRenderer.Component]) -> some View {
        var text = Text("")
        for component in components {
            switch component {
            case let .text(attributedString):
                // swiftlint:disable:next shorthand_operator
                text = text + Text(attributedString)
            case let .image(attatchment):

                let image: Image = attatchment.image ?? Image(systemName: "arrow.down.circle")
                // swiftlint:disable:next shorthand_operator
                text = text + Text(image)
            }
        }
        return text
    }
    
    public var body: some View {
        switch renderer.type {
        case let .text(components, images):
            text(components: components)
                .task {
                    for image in images {
                        await configuration.inlineImageLoader(image)
                    }
                }
        case let .singleImage(image):
            configuration.imageBlockView(image)
        default:
            Text("Error")
        }
    }
}
