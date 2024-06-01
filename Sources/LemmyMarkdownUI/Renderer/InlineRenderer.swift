//
//  InlineRenderer.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

internal extension UIFont {
    static var bodyPointSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
}

internal class InlineRenderer {
    enum InlineType {
        case text(components: [Component], images: [InlineImage])
        case singleImage(image: InlineImage)
    }

    enum Component {
        case text(AttributedString)
        case image(InlineImage)
        
        static func newLine(_ count: Int = 1) -> Self {
            .text(.init(.init(repeating: "\n", count: count)))
        }
        
        var isNewLine: Bool {
            switch self {
            case .text(let attributedString):
                !attributedString.characters.isEmpty && attributedString.characters.allSatisfy(\.isNewline)
            case .image:
                false
            }
        }
    }
    
    var type: InlineType!
    
    private var components: [Component] = .init()
    private var images: [InlineImage] = .init()
    private var currentText: AttributedString = .init()
    
    init(inlines: [InlineNode], configuration: MarkdownConfiguration) {
        renderInlines(inlines: inlines, configuration: configuration)
        components.append(.text(currentText))
        chooseType()
    }
    
    init(blocks: [BlockNode], configuration: MarkdownConfiguration) {
        renderBlocks(blocks: blocks, configuration: configuration, withNewlines: true)
        chooseType()
    }
    
    private func chooseType() {
        if images.count == 1, let image = images.first {
            var isSingleImage = true
            loop: for component in components {
                switch component {
                case let .text(attributedString):
                    if !attributedString.characters.allSatisfy(\.isWhitespace) {
                        isSingleImage = false
                        break loop
                    }
                default:
                    break
                }
            }
            if isSingleImage {
                self.type = .singleImage(image: image)
                return
            }
        }
        self.type = .text(components: components, images: images)
    }
    
    private func renderBlocks(
        blocks: [BlockNode],
        attributes: AttributeContainer = .init(),
        configuration: MarkdownConfiguration,
        withNewlines: Bool = false
    ) {
        for (index, block) in blocks.enumerated() {
            if withNewlines || (index != 0 && index != blocks.count - 1) {
                components.newline(2)
            }
            switch block {
            case let .paragraph(inlines):
                renderInlines(
                    inlines: inlines,
                    attributes: attributes,
                    configuration: configuration
                )
            case let .heading(level: level, inlines: inlines):
                var attributes = attributes
                attributes.font = level.font
                renderInlines(
                    inlines: inlines,
                    attributes: attributes,
                    configuration: configuration
                )
            case let .blockquote(blocks: blocks):
                var attributes = attributes
                attributes.foregroundColor = configuration.quoteColor
                renderBlocks(
                    blocks: blocks,
                    attributes: attributes,
                    configuration: configuration
                )
            case let .spoiler(title: title, blocks: _):
                var attributes = attributes
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.text(.init("[Spoiler] \(title ?? "")", attributes: attributes)))
            case .table:
                var attributes = attributes
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.text(.init("[Table]", attributes: attributes)))
            case let .codeBlock(fenceInfo: _, content: content, truncatedRows: _):
                var attributes = attributes
                attributes.font = .body.monospaced()
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.text(.init(content, attributes: attributes)))
            case let .bulletedList(isTight: _, items: items, truncatedRows: _):
                var bulletAttributes = attributes
                bulletAttributes.foregroundColor = configuration.secondaryColor
                for (index, item) in items.enumerated() {
                    components.append(.text(.init("- ", attributes: bulletAttributes)))
                    renderBlocks(
                        blocks: item.blocks,
                        attributes: attributes,
                        configuration: configuration
                    )
                    components.newline(index == items.count - 1 ? 2 : 1)
                }
            case let .numberedList(isTight: _, start: start, items: items, truncatedRows: _):
                var bulletAttributes = attributes
                bulletAttributes.foregroundColor = configuration.secondaryColor
                for (index, item) in items.enumerated() {
                    components.append(.text(.init("\(start + index). ", attributes: bulletAttributes)))
                    renderBlocks(
                        blocks: item.blocks,
                        attributes: attributes,
                        configuration: configuration
                    )
                    components.newline(index == items.count - 1 ? 2 : 1)
                }
            default:
                break
            }
            if withNewlines || (index != 0 && index != blocks.count - 1) {
                components.newline(2)
            }
        }
        if let last = components.last, last.isNewLine {
            components.removeLast()
        }
        
        print(components)
    }
    
    private func renderInlines(
        inlines: [InlineNode],
        attributes: AttributeContainer = .init(),
        configuration: MarkdownConfiguration,
        isRoot: Bool = true
    ) {
        for node in inlines {
            if let string = node.string {
                // swiftlint:disable:next shorthand_operator
                currentText = currentText + AttributedString(
                    string,
                    attributes: node.applyAttributes(attributes, configuration: configuration)
                )
            } else {
                switch node {
                case let .image(source: source, children: _, truncated):
                    if let url = URL(string: source) {
                        components.append(.text(currentText))
                        currentText = .init()
                        let attatchment = InlineImage(
                            url: url,
                            fontSize: attributes.uiKit.font?.pointSize ?? UIFont.bodyPointSize,
                            truncated: truncated
                        )
                        images.append(attatchment)
                        components.append(.image(attatchment))
                    }
                default:
                    renderInlines(
                        inlines: node.inlineChildren,
                        attributes: node.applyAttributes(attributes, configuration: configuration),
                        configuration: configuration,
                        isRoot: false
                    )
                }
            }
        }
        if isRoot {
            components.append(.text(currentText))
            currentText = .init()
        }
    }
}

extension [InlineRenderer.Component] {
    func text(configuration: MarkdownConfiguration) -> Text {
        var text = Text("")
        for component in self {
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
    
    mutating func newline(_ count: Int = 1) {
        if let last, !last.isNewLine {
            append(.newLine(count))
        }
    }
}
