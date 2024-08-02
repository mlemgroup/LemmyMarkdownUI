//
//  InlineNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

internal extension InlineNode {
    func applyAttributes(
        _ attributes: AttributeContainer,
        configuration: MarkdownConfiguration
    ) -> AttributeContainer {
        let font: UIFont = (attributes.uiKit.font) ?? configuration.font
        var attributes = attributes
        switch self {
        case .emphasis:
            attributes.uiKit.font = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitItalic)
                )!,
                size: font.pointSize
            )
        case .strong:
            attributes.uiKit.font = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitBold)
                )!,
                size: font.pointSize
            )
        case .code:
            attributes.font = Font(font).monospaced()
            attributes.backgroundColor = configuration.codeBackgroundColor
        case .superscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
            attributes.baselineOffset = UIFont.bodyPointSize / 3
        case .subscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
        case .strikethrough:
            attributes.strikethroughStyle = .single
        case let .link(destination: url, children: _):
            attributes.link = URL(string: url)
        case .truncationTerminator:
            attributes.foregroundColor = configuration.secondaryColor
        default:
            break
        }
        return attributes
    }
}
