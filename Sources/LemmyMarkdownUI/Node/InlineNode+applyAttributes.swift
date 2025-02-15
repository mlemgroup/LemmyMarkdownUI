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
        var font: UIFont = (attributes.uiKit.font) ?? configuration.font
        var attributes = attributes
        attributes.uiKit.font = font
        switch self {
        case .emphasis:
            attributes.uiKit.font = font.unionWithTrait(.traitItalic)
        case .strong:
            attributes.uiKit.font = font.unionWithTrait(.traitBold)
        case .code:
            font = font.withSize(font.pointSize * configuration.codeFontScaleFactor)
            attributes.font = Font(font).monospaced()
            attributes.backgroundColor = configuration.codeBackgroundColor
        case .censored:
            attributes.uiKit.font = font.unionWithTrait(.traitItalic)
            attributes.backgroundColor = configuration.censorColor.opacity(0.15)
            attributes.foregroundColor = configuration.censorColor
        case .superscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
            attributes.baselineOffset = UIFont.bodyPointSize / 3
        case .subscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
        case .strikethrough:
            attributes.strikethroughStyle = .single
        case let .link(destination: url, _, children: _):
            attributes.link = URL(string: url)
        default:
            break
        }
        return attributes
    }
}

private extension UIFont {
    func unionWithTrait(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        .init(
            descriptor: fontDescriptor.withSymbolicTraits(
                fontDescriptor.symbolicTraits.union(traits)
            )!,
            size: pointSize
        )
    }
}
