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
    enum Component: Hashable {
        case text(AttributedString)
        case image(MarkdownImage)
        
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
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .text(attributedString):
                hasher.combine(attributedString)
            case let .image(image):
                hasher.combine(image.url)
            }
            
        }
        
        static func == (lhs: Component, rhs: Component) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }
    
    var components: [Component] = .init()
    var images: [MarkdownImage] = .init()
    
    private let configuration: MarkdownConfiguration
    private var indent: Int = 0
    private var currentText: AttributedString = .init()
    private var count = 0
    
    init(inlines: [InlineNode], configuration: MarkdownConfiguration) {
        self.configuration = configuration
        renderInlines(inlines: inlines)
    }
    
    init(blocks: [BlockNode], configuration: MarkdownConfiguration) {
        self.configuration = configuration
        renderBlocks(blocks: blocks, withNewlines: true)
    }
    
    private func renderBlocks(
        blocks: [BlockNode],
        attributes: AttributeContainer = .init(),
        withNewlines: Bool = false
    ) {
        count += 1
        for (index, block) in blocks.enumerated() {
            if withNewlines || (index != 0) {
                components.newline(2)
            }
            switch block {
            case let .paragraph(inlines):
                renderInlines(
                    inlines: inlines,
                    attributes: attributes
                )
            case let .heading(level: level, inlines: inlines):
                var attributes = attributes
                attributes.font = level.font
                renderInlines(
                    inlines: inlines,
                    attributes: attributes
                )
            case let .blockquote(blocks: blocks):
                var attributes = attributes
                attributes.foregroundColor = configuration.quoteColor
                renderBlocks(
                    blocks: blocks,
                    attributes: attributes
                )
            case let .spoiler(title: title, blocks: _):
                var attributes = attributes
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.init("[Spoiler] \(title ?? "")", attributes: attributes), indent: indent)
            case .table:
                var attributes = attributes
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.init("[Table]", attributes: attributes), indent: indent)
            case let .codeBlock(fenceInfo: _, content: content):
                var attributes = attributes
                attributes.font = .body.monospaced()
                attributes.foregroundColor = configuration.secondaryColor
                components.append(.init(content, attributes: attributes), indent: indent)
            case let .bulletedList(isTight: _, items: items):
                var bulletAttributes = attributes
                bulletAttributes.foregroundColor = configuration.secondaryColor
                for (index, item) in items.enumerated() {
                    components.append(.init("- ", attributes: bulletAttributes), indent: indent)
                    renderBlocks(
                        blocks: item.blocks,
                        attributes: attributes
                    )
                    components.newline(index == items.count - 1 ? 2 : 1)
                }
            case let .numberedList(isTight: _, start: start, items: items):
                var bulletAttributes = attributes
                bulletAttributes.foregroundColor = configuration.secondaryColor
                for (index, item) in items.enumerated() {
                    components.append(.init("\(start + index). ", attributes: bulletAttributes), indent: indent)
                    renderBlocks(
                        blocks: item.blocks,
                        attributes: attributes
                    )
                    components.newline(index == items.count - 1 ? 2 : 1)
                }
            default:
                break
            }
            if withNewlines || (index != blocks.count - 1) {
                components.newline(2)
            }
        }
        if let last = components.last, last.isNewLine {
            components.removeLast()
        }
    }
    
    private func renderInlines(
        inlines: [InlineNode],
        attributes: AttributeContainer = .init(),
        isRoot: Bool = true,
        parentLink: String? = nil
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
                case let .image(source: source, tooltip: tooltip, children: children):
                    if let url = URL(string: source) {
                        commitCurrentText()
                        let attatchment = MarkdownImage(
                            children: children,
                            url: url,
                            tooltip: tooltip,
                            fontSize: attributes.uiKit.font?.pointSize ?? UIFont.bodyPointSize,
                            parentLink: parentLink
                        )
                        images.append(attatchment)
                        components.append(.image(attatchment))
                    }
                case let .link(destination: destination, tooltip: _, children: inlineChildren):
                    renderInlines(
                        inlines: inlineChildren,
                        attributes: node.applyAttributes(attributes, configuration: configuration),
                        isRoot: false,
                        parentLink: destination
                    )
                default:
                    renderInlines(
                        inlines: node.inlineChildren,
                        attributes: node.applyAttributes(attributes, configuration: configuration),
                        isRoot: false
                    )
                }
            }
        }
        if isRoot {
            commitCurrentText()
        }
    }
    
    private func commitCurrentText() {
        if !currentText.characters.isEmpty {
            components.append(currentText, indent: indent)
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

                let image: Image = attatchment.image ?? Image(systemName: configuration.unloadedImageIcon)
                // swiftlint:disable:next shorthand_operator
                text = text + Text(image).foregroundStyle(configuration.secondaryColor)
            }
        }
        return text
    }
    
    mutating func newline(_ count: Int = 1) {
        if let last, !last.isNewLine {
            append(.newLine(count))
        }
    }
    
    mutating func append(_ value: AttributedString, indent: Int) {
        append(.text(AttributedString.init(String(repeating: " ", count: indent * 4)) + value))
    }
    
    func grouped(configuration: MarkdownConfiguration) -> [[InlineRenderer.Component]] {
        var output: [[InlineRenderer.Component]] = []
        var current: [InlineRenderer.Component] = []
        for component in self {
            switch component {
            case let .image(image):
                let presentationMode: FinalImagePresentationMode = switch configuration.imagePresentationMode {
                case .contextual: image.renderFullWidth ? .block : .inline
                case .block: .block
                case .inline : .inline
                }
                switch presentationMode {
                case .block:
                    if !current.isEmpty {
                        output.append(current)
                    }
                    output.append([component])
                    current = []
                case .inline:
                    current.append(component)
                }
            case .text:
                current.append(component)
            }
        }
        if !current.isEmpty {
            output.append(current)
        }
        return output
    }
}

private enum FinalImagePresentationMode {
    case block, inline
}
