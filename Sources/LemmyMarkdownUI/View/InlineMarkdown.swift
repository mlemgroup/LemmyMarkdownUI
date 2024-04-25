//
//  InlineMarkdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct InlineMarkdown<ImageView: View>: View {
    
    var renderer: InlineRenderer
    var inlineImageLoader: (InlineImage) async -> Void
    @ViewBuilder var imageBlockView: (_ image: InlineImage) -> ImageView
    
    public init(
        _ markdown: String,
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        @ViewBuilder imageBlockView: @escaping (_ image: InlineImage) -> ImageView
    ) {
        self.init(
            [InlineNode].init(markdown),
            inlineImageLoader: inlineImageLoader,
            imageBlockView: imageBlockView
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        @ViewBuilder imageBlockView: @escaping (_ image: InlineImage) -> ImageView
    ) {
        self.renderer = .init(inlines: inlines)
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
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
                        await inlineImageLoader(image)
                    }
                }
        case let .singleImage(image):
            imageBlockView(image)
        default:
            Text("Error")
        }
    }
}
