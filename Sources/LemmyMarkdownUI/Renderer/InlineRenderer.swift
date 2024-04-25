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
    }
    
    var type: InlineType!
    
    private var components: [Component] = .init()
    private var images: [InlineImage] = .init()
    private var currentText: AttributedString = .init()
    
    init(inlines: [InlineNode]) {
        renderInlines(inlines: inlines)
        components.append(.text(currentText))
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
    
    private func renderInlines(
        inlines: [InlineNode],
        attributes: AttributeContainer = .init()
    ) {
        for node in inlines {
            if let string = node.string {
                // swiftlint:disable:next shorthand_operator
                currentText = currentText + AttributedString(string, attributes: node.applyAttributes(attributes))
            } else {
                switch node {
                case let .image(source: source, children: _):
                    if let url = URL(string: source) {
                        components.append(.text(currentText))
                        currentText = .init()
                        let attatchment = InlineImage(
                            url: url,
                            fontSize: attributes.uiKit.font?.pointSize ?? UIFont.bodyPointSize
                        )
                        images.append(attatchment)
                        components.append(.image(attatchment))
                    }
                default:
                    renderInlines(
                        inlines: node.inlineChildren,
                        attributes: node.applyAttributes(attributes)
                    )
                }
            }
        }
    }
}
